# TSX Template

Drop in your TSX component in `src/ReplaceMeExample.tsx` and deploy on Lima City.

## Quickstart
- `npm install`
- `npm run dev`
- `npm run build`

## Swap the main component
Use the helper script to drop in your TSX file:

- `bash scripts/replace-component.sh ./YourComponent.tsx`
- The script expects a `.tsx` file path. It will:
  - Copy it into `src/` (renaming the component to a PascalCase name if needed)
  - Remove `src/ReplaceMeExample.tsx`
  - Rewrite `src/main.tsx` to import and render your component
  - Update `index.html` title to the component name
  - Add any bare imports it finds to `package.json` (with `latest` versions)
After running, execute `npm install` to pick up any newly added dependencies.

## Build/Deploy
Build artifacts land in `dist/`.

## Run inside a Pipenv shell
You can run the Node/Vite workflow inside a Pipenv shell as long as npm is available.
- `pipenv shell` (ensure Node/npm are on PATH inside it)
- `npm install`
- `npm run dev` to develop, or `npm run build` to verify the build (output goes to `dist/`)
- If npm isn’t available in the Pipenv shell, install Node there first (e.g., `pipenv install nodeenv` then `nodeenv -p`), then rerun the steps above.
