# Canteen frontend

Small React client for the Campus Canteen API. Requires Node.js 18 or newer.

1. Start the backend first (`scripts/run-backend.ps1`), so http://localhost:8080 is up.
2. In this folder: `npm install`, then `npm run dev`.
3. Open http://localhost:5173 (the port is fixed because the backend's CORS rule only allows 5173 and 3000).

Log in with a sample account (password `Password123!`): `maria@student.test`, `nena@vendor.test` or `admin@canteen.test`.
Put this folder at `frontend/` in the repository root. If you change the backend address, edit `API` at the top of `src/App.jsx`.
