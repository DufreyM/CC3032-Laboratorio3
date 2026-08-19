# CC3032 — Laboratorio 3, Opción D: GitHub + Vercel

Compilador de un DSL propio llamado **SiteLang**, construido con ANTLR. Parsea un archivo
`.sl` que describe un sitio web, genera el HTML correspondiente, crea un repositorio en
GitHub, sube el HTML y despliega el sitio en Vercel — todo con una sola ejecución.

## Estructura

```
.
├── Dockerfile
├── requirements.txt
├── python-venv.sh
├── commands/
│   ├── antlr            # wrapper para invocar antlr4
│   └── grun              # wrapper para TestRig (pruebas de gramática)
├── program/
│   ├── SiteLang.g4        # gramática ANTLR del DSL
│   ├── Driver.py           # punto de entrada del compilador
│   ├── SiteListener.py     # listener: genera HTML y llama a las APIs
│   ├── site.sl             # programa de ejemplo (edítalo con tus datos)
│   └── .env.example        # plantilla de variables de entorno
└── scripts/                # exploración manual de las APIs con curl (Parte 1 del lab)
```

## Uso

### 1. Tokens

Necesitas:
- Un **GitHub Personal Access Token** (classic) con scope `repo` — [github.com/settings/tokens](https://github.com/settings/tokens)
- Un **Vercel API Token** — [vercel.com/account/tokens](https://vercel.com/account/tokens)

Copia la plantilla y complétala:

```bash
cp program/.env.example program/.env
```

```
GITHUB_TOKEN=ghp_...
VERCEL_TOKEN=...
```

`program/.env` está en `.gitignore` y nunca debe subirse al repositorio.

### 2. Personaliza tu sitio

Edita `program/site.sl` con tu nombre, título, descripción y contacto.

### 3. Construye la imagen

```bash
docker build --rm . -t lab3-vercel
```

### 4. Corre el compilador

```bash
docker run --rm \
  --env-file program/.env \
  -v "$(pwd)/program":/program \
  lab3-vercel bash -c "antlr -Dlanguage=Python3 -listener SiteLang.g4 && python3 Driver.py site.sl"
```

Al terminar imprime la URL pública del sitio desplegado en Vercel.

## Qué hace el compilador

1. **ANTLR** tokeniza y parsea `site.sl` según la gramática `SiteLang.g4`.
2. `SiteListener` recorre el árbol sintáctico y extrae metadata y contenido.
3. Genera `index.html` (generación de código).
4. Llama a la API de GitHub para crear el repositorio y subir el HTML.
5. Llama a la API de Vercel para desplegar el HTML directamente.

Ver [ANALYSIS.md](ANALYSIS.md) para la comparación con el funcionamiento interno de
Vercel CLI / Netlify CLI.

## Créditos

Boilerplate del laboratorio: [gbrolo/compilers-2026](https://github.com/gbrolo/compilers-2026/tree/main/lab-3/option-vercel) — CC3032 Construcción de Compiladores, UVG.
