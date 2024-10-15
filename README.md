# InsightNet 2024 Workshop

Working materials.

---

Development notes.

### Organization

* Top directory controls the website.
* Any directory beginning with `_` will not be built.
* In the top directory, I put code files that I will source (or call in other
places) in `_code/`. 
* Same goes for the `slides/_code/`: it's a good place for long scripts to be
used inside the `.qmd` files. But it's helpful to name them similar to the
code chunk in which they're used.

### Building the site

Currently, the site builds, but no code is run. So you must first 
[Render Website] locally. The whole thing, not just the slides you're working
on. We can adjust this later if it's helpful. 
* To do this, either click Build > Render Website or call `quarto::quarto_render()`.

So be careful to cache computations if you don't want it to run forever.

