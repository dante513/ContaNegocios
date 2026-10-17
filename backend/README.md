# Backend de ContaNegocios

API REST en Node.js + Express. Estructura y reglas: `docs/02-diseno/01-arquitectura.md` y `docs/03-desarrollo/01-guia-de-desarrollo.md`.

## Primer arranque

```powershell
cd backend
npm install
copy ..\.env.example ..\.env     # crea .env en la raíz del repositorio; completar los valores
npm run dev
```

Verifica en el navegador: `http://localhost:3000/api/v1/salud`

## Scripts

| Comando | Qué hace |
|---|---|
| `npm run dev` | Arranca con reinicio automático al guardar cambios |
| `npm start` | Arranca sin reinicio automático |
| `npm test` | Ejecuta las pruebas |

## Configuración

El backend lee el archivo `.env` de la **raíz del repositorio** (junto a `.env.example`), sin importar desde qué carpeta lo ejecutes. **Nunca se sube a GitHub** (el `.gitignore` lo excluye).
