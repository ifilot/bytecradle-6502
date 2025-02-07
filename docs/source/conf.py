# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'ByteCradle 6502'
copyright = '2025, Ivo Filot'
author = 'Ivo Filot'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.mathjax',
    'sphinx_rtd_theme',
    'sphinx.ext.autodoc',
    'sphinx_design',
    'sphinx_subfigure',
    'myst_parser'
]

templates_path = ['_templates']
exclude_patterns = []

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'pydata_sphinx_theme'

html_theme_options = {
    "navbar_start": ["navbar-logo"],
    "navbar_center": ["navbar-nav"],
    "navbar_align": "content",
    "navbar_end": ["navbar-icon-links"],
    "navbar_persistent": ["search-button"],
    "logo": {
        "text": "ByteCradle 6502",
        "image_light": "_static/img/sap-smd-32px.png",
        "image_dark": "_static/img/sap-smd-32px.png",
    }
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
master_doc = 'index'
html_static_path = ['_static']
html_logo = "_static/img/sap-smd-32px.png"
html_favicon = "_static/img/favicon.ico"
html_css_files = [
    "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css",
    "css/custom.css"
]

# other options
html_show_sourcelink = False

# myst options
myst_heading_anchors = 3
numfig_secnum_depth = 1
numfig = True
