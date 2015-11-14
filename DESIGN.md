# Design

## View

### Auto reload

client: phoenix_live_reload.js
server: in crystal app?

### URL Helpers

Shortcuts available in Controllers, Views (and specs?)

Each route has a named method with args representing dynamic url parts

### Javscript

View over the wire? https://www.youtube.com/watch?v=eBccDerJPJE&list=WL&index=17

## Dispatch

### Router

Rails.application.routes.draw...

- Crystral router: https://github.com/bcardiff/crystal-routing
- httprouter is the fastest Go router using a "compressing dynamic trie (radix tree)" algorithm (but no subdomain support): https://github.com/julienschmidt/httprouter
- Crystalline has Trie container: https://github.com/jtomschroeder/crystalline

### Notes

- Go has fairly advanced http library
- Gorilla is a selection of Go middleware: http://www.gorillatoolkit.org/pkg/context
- Mango does Rack style API in Go: https://github.com/paulbellamy/mango

## Persistance

Domain Driven (entities, repos, data mapper etc) - https://github.com/lotus/model

Event Sourcing? https://www.youtube.com/watch?v=dOlTRl8gJIs&list=WL&index=18

- Data Mapper: Separate all persistance logic from domain model (but peristance service understand domain object?)
- Active Record: Domain object knows itself how to save/delete itself etc from persistant storage
- Anemic domain model: anti pattern separating data/behaviour of domain models into services
- GraphQL?

Domain model: http://martinfowler.com/eaaCatalog/domainModel.html

DM vs AR: http://jgaskins.org/blog/2012/04/20/data-mapper-vs-active-record/ - doesn't give a good example of DM

## Javascript?
