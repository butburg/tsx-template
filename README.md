# TSX Template

Drop in your TSX component in `src/ReplaceMeExample.tsx` and deploy on your host.

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

## Deploy via GitHub Actions (SSH)
- Workflow auto-runs on `main` pushes and can be triggered manually via *Actions → Deploy → Run workflow*.
- Required GitHub secrets: `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY` (the private key for the remote host), optional `SSH_PORT` (defaults to 22), optional `SSH_KNOWN_HOSTS` (if you don’t want the workflow to ssh-keyscan).
- Repo variable: `REMOTE_DIR` (remote path for the build). If not set, the workflow falls back to the repository name (e.g., `tsx-template`). Manual runs can also override with the `target` input.
- What it does: checkout → validate required secrets → ensure lockfile → install → build → set up SSH → test SSH → `rsync` `dist/` to the target path on the host. Secrets must be added in the GitHub repo that uses this template; they cannot live in the template itself.

## Build/Deploy
Build artifacts land in `dist/`.

## Run inside a Pipenv shell for dev
You can run the Node/Vite workflow inside a Pipenv shell as long as npm is available.
- `pipenv shell` (ensure Node/npm are on PATH inside it)
- `npm install`
- `npm run dev` to develop, or `npm run build` to verify the build (output goes to `dist/`)
- If npm isn’t available in the Pipenv shell, install Node there first (e.g., `pipenv install nodeenv` then `nodeenv -p`), then rerun the steps above.
