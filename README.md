# A Beamer template for UGE/Inria

## Why this repository ?
The official template of the University is not convenient enough.
For a long time, LaTeX/Beamer users were forgotten.

Since we are a common team, we have to switch between our two institutes templates regularly.


## What is it ?
The purpose of this LaTeX/Beamer theme is to provide a template for presentations at Université Gustave Eiffel or Inria.


## Warning
!!! This not an official template !!! 

Despite our efforts, we are not respecting *strictly* the graphical charter, we prioritized ergonomic and reading solutions.
However, thanks to Oliver FRANÇOIS, an official Beamer template, respecting graphical charter, can be found at: https://intranet.univ-eiffel.fr/communication/logos-et-documents-chartes .
Many other PowerPoint materials can also be found at the previous link.

But our template is much more convenient and prettier.


## How to use/install
There is two major ways to use this template: downloading from Git or "make a copy" from Overleaf.

- Github link: https://github.com/Universite-Gustave-Eiffel/beamer-template_uge-inria

  If you have a LaTeX distribution installed on your comptuer, you can download the sources by clicking on `<> Code`/`Download ZIP`.
  After extracting the sources, you can directly edit (and probably rename) the file `Ready2Go.tex`.
  Then, you can compile your presentation using your favorite LaTeX compiler (pdflatex, xelatex, luatex, arara, latexmk...).
  If you use the `glossaires` package (or some others) as given in the example, do not forget to add the compilation option `--shell-escape`.
  This remark stands also for your favorite LaTeX IDE (~~VSCode~~ Codium, TeXStudio, TeXMaker, Lyx, Emacs, ...)
  Compilation command example: `pdflatex output.pdf Ready2Go.tex --shell-escape`.

- Overleaf link (read only): https://www.overleaf.com/read/vxnjgfmyvccj

  If you do not want to install a LaTeX distribution or just want to try first, on Overleaf you can click on `Make a copy` (or `copy project`, according to where you are).
  This copy will be editable so you will be able to play around. 


## Features
- metropolis based
- 4/3 and 16/9
- dark and light theme
- edging
- watermark
- rotation of the footer
- standin
- content of the section
- extra institute logo easy to custom
- some tips and good practices
- etc.


## Demonstration files
- **Demo_metroUGE_dark43**
- **Demo_metroUGE_light169**: contains examples and a very incomplete documentation. It is recommended to start by reading this PDF file (and the associated TeX if needed).
- Demo_WoMT
- **Simplest_example**


## How to contribute
- raising [issues](https://github.com/Universite-Gustave-Eiffel/beamer-template_uge-inria/issues) on git
- giving stars on git
- buying us a coffee
- mailing us 

## Credits
The previous version of the repo was hosted here: https://github.com/KirmTwinty/uge-beamer