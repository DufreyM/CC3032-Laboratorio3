# Define tu sitio aquí.
# Al correr el compilador se genera el HTML, se crea el repo en GitHub y se despliega a Vercel.

site "leonardo-mejia-dev" {
  title       = "Leonardo Mejía — Backend Developer"
  description = "Backend developer que trabaja principalmente con Golang, estudiante de Ciencias de la Computación en la UVG"
  theme       = "dark"

  page "index" {
    hero    = "Hola, soy Leonardo Mejía"
    about   = "Soy backend developer y trabajo principalmente con Golang. Estudio Ciencias de la Computación en la Universidad del Valle de Guatemala. Cuando no estoy programando, probablemente estoy jugando algo de Pokémon."
    contact = "leomejia646@gmail.com"
  }
}
