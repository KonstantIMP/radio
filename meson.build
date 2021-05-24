project('radio', ['c', 'd'])

gnome = import('gnome')

gtkd_dep = dependency('gtkd-3')
gtk_dep = dependency('gtk+-3.0')

source_root = meson.source_root()
sources_dir = include_directories('source/')

resources_dir = 'resource/'

radio_sources = [
    'source/app.d',
    'source/radio/win.d',
    'source/radio/plot.d',
    'source/radio/array.d',
    'source/radio/modulation.d'
]

radio_resources = [
    gnome.compile_resources('radio_resorces',    
    files('resource/radio.gresource.xml'),
    source_dir : [resources_dir],   
    c_name : 'radio'
    )
]

radio_bin = executable('radio',
    [radio_sources, radio_resources],
    include_directories : [sources_dir],
    dependencies : [gtkd_dep, gtk_dep]
)