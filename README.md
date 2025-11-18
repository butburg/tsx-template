# TSX Template

Drop in your TSX component in `src/ReplaceMeExample.tsx` and deploy on Lima City.

## Quickstart
- `npm install`
- `npm run dev`
- `npm run build`

## Swap the main component
Edit `src/ReplaceMeExample.tsx`, then ensure `src/main.tsx` imports and renders it.

## Build/Deploy
Build artifacts land in `dist/`.

## Run inside a Pipenv shell
You can run the Node/Vite workflow inside a Pipenv shell as long as npm is available.
- `pipenv shell` (ensure Node/npm are on PATH inside it)
- `npm install`
- `npm run dev` to develop, or `npm run build` to verify the build (output goes to `dist/`)
- If npm isn’t available in the Pipenv shell, install Node there first (e.g., `pipenv install nodeenv` then `nodeenv -p`), then rerun the steps above.
