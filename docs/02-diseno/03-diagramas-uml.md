# Diagramas UML

> Versión 0.1 · 17-oct-2026 · Estado: borrador. Diagramas en Mermaid (se ven directo en GitHub). Coherentes con `02-modelo-de-datos.md`, `04-api.md` y las historias de usuario (HU).

## 1. Casos de uso

Mermaid no tiene un diagrama de casos de uso nativo; se representa con actores y casos de uso en un diagrama de flujo. Entre paréntesis, la historia de usuario.

```mermaid
flowchart LR
    CON(["Contador"])
    AUX(["Auxiliar"])
    CLI(["Cliente"])

    subgraph ACC["Acceso"]
        UC1("Iniciar sesión · HU-01")
        UC2("Gestionar usuarios y permisos · HU-02")
    end
    subgraph CLN["Clientes y movimientos"]
        UC3("Registrar cliente · HU-10")
        UC4("Consultar expediente · HU-11")
        UC5("Adjuntar soportes · HU-12")
        UC6("Registrar movimiento · HU-20")
        UC7("Importar extracto · HU-21")
        UC8("Anular movimiento")
    end
    subgraph PAR["Parámetros"]
        UC9("Consultar parámetros vigentes · HU-30")
        UC10("Preparar año nuevo · HU-31")
        UC11("Aprobar y activar año · HU-32")
        UC12("Registrar cambio a mitad de año · HU-33")
    end
    subgraph OBL["Obligaciones y papeles de trabajo"]
        UC13("Ver semáforo de topes · HU-40")
        UC14("Ver obligación de exógena · HU-41")
        UC15("Ver calendario · HU-42")
        UC16("Controlar GMF · HU-50")
        UC17("Generar borrador de renta · HU-60")
        UC18("Generar papel de trabajo de exógena · HU-61")
        UC19("Exportar a Excel o PDF · HU-62")
    end
    subgraph NOM["Nómina"]
        UC20("Liquidar nómina · HU-70")
        UC21("Ver provisiones · HU-71")
    end
    UC22("Consultar bitácora · HU-81")

    CON --- UC1 & UC2 & UC3 & UC4 & UC5 & UC6 & UC7 & UC8
    CON --- UC9 & UC10 & UC11 & UC12
    CON --- UC13 & UC14 & UC15 & UC16 & UC17 & UC18 & UC19
    CON --- UC20 & UC21 & UC22
    AUX --- UC1 & UC4 & UC5 & UC6 & UC7 & UC9 & UC13 & UC16
    CLI --- UC1 & UC5 & UC13 & UC15
```

## 2. Diagrama de clases del dominio

Modelo conceptual (no incluye servicios ni controladores). Los atributos corresponden a las columnas de `02-modelo-de-datos.md`.

```mermaid
classDiagram
    class Usuario {
        +id
        +nombre
        +correo
        +rol
        +activo
        +bloqueadoHasta
        +iniciarSesion()
        +cambiarClave()
    }
    class Cliente {
        +id
        +tipoPersona
        +tipoContribuyente
        +esEmpleador
        +ultimosDigitos
        +activo
    }
    class CuentaBancaria {
        +banco
        +ultimos4
        +marcadaGmf
    }
    class Tercero {
        +tipoDocumento
        +nombre
    }
    class Categoria {
        +nombre
        +cedulaRenta
        +conceptoExogena
    }
    class Movimiento {
        +fecha
        +anioGravable
        +tipo
        +valor
        +anuladoEn
        +motivoAnulacion
        +anular(motivo)
    }
    class Soporte {
        +nombreArchivo
        +hashArchivo
    }
    class Activo {
        +anioGravable
        +descripcion
        +valor31Dic
    }
    class ConjuntoParametros {
        +anio
        +estado
        +enviarARevision()
        +activar()
    }
    class Parametro {
        +codigo
        +valor
        +unidad
        +operador
        +vigenteDesde
        +vigenteHasta
        +fuenteNorma
        +nivelVerificacion
        +estado
    }
    class Calculo {
        +tipo
        +anioGravable
        +resultado
        +parametrosUsados
    }
    class Empleado {
        +nombre
        +fechaIngreso
        +salarioBase
    }
    class Nomina {
        +anio
        +mes
        +estado
        +liquidar()
    }
    class NominaDetalle {
        +salario
        +auxilioTransporte
        +descuentoSalud
        +descuentoPension
        +neto
    }
    class Bitacora {
        +accion
        +entidad
        +antes
        +despues
        +creadoEn
    }

    Usuario "1" --> "*" Bitacora : ejecuta
    Usuario "*" --> "*" Cliente : accede a
    Cliente "1" *-- "*" CuentaBancaria
    Cliente "1" *-- "*" Tercero
    Cliente "1" *-- "*" Movimiento
    Cliente "1" *-- "*" Activo
    Cliente "1" *-- "*" Empleado
    Cliente "1" *-- "*" Nomina
    Cliente "1" --> "*" Calculo : obtiene
    Categoria "1" --> "*" Movimiento : clasifica
    Tercero "0..1" --> "*" Movimiento : interviene
    CuentaBancaria "0..1" --> "*" Movimiento : origina
    Movimiento "1" *-- "*" Soporte
    Nomina "1" *-- "*" NominaDetalle
    Empleado "1" --> "*" NominaDetalle : liquida
    ConjuntoParametros "1" *-- "*" Parametro
    Usuario "1" --> "*" ConjuntoParametros : crea
```

## 3. Diagramas de secuencia

### 3.1 Iniciar sesión (HU-01)

```mermaid
sequenceDiagram
    actor U as Usuario
    participant F as Frontend
    participant A as API
    participant DB as PostgreSQL
    U->>F: Correo y contraseña
    F->>A: POST /auth/login
    A->>DB: Busca usuario por correo
    alt Usuario bloqueado
        A-->>F: 429 Demasiados intentos
    else Credenciales válidas
        A->>DB: Reinicia intentos fallidos
        A->>DB: Registra inicio de sesión en bitácora
        A-->>F: 200 y cookie httpOnly
    else Credenciales inválidas
        A->>DB: Suma intento fallido; bloquea si corresponde
        A-->>F: 401 "Credenciales inválidas"
    end
```

### 3.2 Registrar un movimiento (HU-20)

```mermaid
sequenceDiagram
    actor X as Auxiliar
    participant F as Frontend
    participant A as API
    participant S as Servicio de movimientos
    participant DB as PostgreSQL
    X->>F: Completa el formulario
    F->>A: POST /clientes/12/movimientos
    A->>A: Valida sesión, CSRF y rol
    A->>A: ¿Tiene acceso al cliente 12?
    A->>S: crearMovimiento(datos)
    S->>S: Valida campos (valor mayor que cero, fecha, categoría)
    S->>DB: Inserta el movimiento
    S->>DB: Inserta en bitácora (antes y después)
    S-->>A: Movimiento creado
    A-->>F: 201
    F-->>X: Movimiento en la lista y semáforo actualizado
```

### 3.3 Activar el año nuevo (HU-32)

```mermaid
sequenceDiagram
    actor C as Contador
    participant F as Frontend
    participant A as API
    participant S as Servicio de parámetros
    participant DB as PostgreSQL
    C->>F: Pulsa "Activar año 2027"
    F->>A: POST /parametros/conjuntos/7/activar
    A->>S: activarConjunto(7, usuario)
    S->>DB: Lee conjunto y parámetros
    S->>S: ¿Estado en revisión? ¿Todos tienen fuente?
    S->>S: ¿Aprobador distinto del creador? (si hay más de un usuario)
    alt Alguna validación falla
        S-->>A: 422 con el motivo
        A-->>F: Error
    else Todo correcto
        S->>DB: BEGIN
        S->>DB: Conjunto anterior pasa a histórico y sus parámetros se cierran
        S->>DB: Parámetros nuevos pasan a activo con aprobador y fecha
        S->>DB: Inserta en bitácora
        S->>DB: COMMIT
        S-->>A: Año activado
        A-->>F: 200
        F-->>C: Checklist de enero y reporte de diferencias
    end
```

### 3.4 Liquidar una nómina (HU-70)

```mermaid
sequenceDiagram
    actor C as Contador
    participant A as API
    participant S as Servicio de nómina
    participant MR as Motor de reglas
    participant DB as PostgreSQL
    C->>A: POST /nominas/45/liquidar
    A->>S: liquidar(45)
    S->>DB: Lee empleados y periodo
    loop Por cada empleado
        S->>MR: calcular(salario, fecha del periodo)
        MR->>DB: obtenerParametro(SMMLV, AUXILIO_TRANSPORTE, aportes, fecha)
        DB-->>MR: Valores vigentes en esa fecha
        MR-->>S: Detalle con parámetros usados
    end
    S->>DB: Guarda detalle, estado liquidada y bitácora
    S-->>A: Nómina liquidada
    A-->>C: 200
```

## 4. Diagramas de estados

### 4.1 Conjunto de parámetros de un año

```mermaid
stateDiagram-v2
    [*] --> borrador : Contador crea el año
    borrador --> en_revision : Envía a revisión
    en_revision --> borrador : Devuelve para corregir
    en_revision --> activo : Aprueba y activa
    activo --> historico : Se activa el año siguiente
    historico --> [*]
```

### 4.2 Nómina

```mermaid
stateDiagram-v2
    [*] --> borrador : Se crea el periodo
    borrador --> liquidada : Liquidar
    liquidada --> borrador : Reabrir con motivo
    liquidada --> cerrada : Cerrar periodo
    cerrada --> [*]
```

### 4.3 Movimiento

```mermaid
stateDiagram-v2
    [*] --> registrado : Se crea
    registrado --> registrado : Se edita (queda en bitácora)
    registrado --> anulado : Contador anula con motivo
    anulado --> [*]
```

## 5. Diagrama de actividad: temporada de renta de un cliente

```mermaid
flowchart TD
    A(["Inicio del año de presentación"]) --> B["Verificar que los parámetros del año gravable están activos"]
    B --> C["Registrar o importar movimientos, activos y soportes"]
    C --> D["Revisar semáforo de topes"]
    D --> E{"¿Supera algún tope?"}
    E -- "No" --> F{"¿Declaración voluntaria?"}
    F -- "No" --> Z(["Sin obligación: archivar expediente"])
    F -- "Sí" --> G
    E -- "Sí" --> G["Controlar GMF y deducciones"]
    G --> H["Generar borrador de renta"]
    H --> I{"¿Debe reportar exógena?"}
    I -- "Sí" --> J["Generar papel de trabajo de exógena"]
    I -- "No" --> K
    J --> K["Exportar a Excel o PDF"]
    K --> L["Presentar en el portal de la DIAN (fuera del sistema)"]
    L --> M(["Fin"])
```

## 6. Trazabilidad

| Diagrama | Historias y requisitos |
|---|---|
| Casos de uso | HU-01 a HU-81 |
| Clases | `02-modelo-de-datos.md`, RF-10 a RF-63 |
| Secuencia 3.1 | HU-01, RNF-01 |
| Secuencia 3.2 | HU-20, RF-04, RNF-03 |
| Secuencia 3.3 | HU-32, RF-32, RF-33, RN-61, RN-62 |
| Secuencia 3.4 | HU-70, RF-63, RN-01 |
| Estados | RF-31, RF-32, RF-33, RF-61, ADR-011 |
| Actividad | HU-40, HU-50, HU-60, HU-61, RN-10 a RN-16 |
