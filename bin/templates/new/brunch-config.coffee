# See http://brunch.io/#documentation for docs

exports.config =
  files:
    javascripts:
      joinTo: "javascripts/application.js"
    stylesheets:
      joinTo: "stylesheets/application.css"
    templates:
      joinTo: "javascripts/application.js"
  conventions:
    assets: /^(assets\/static)/
  paths:
    watched: ["assets"]
