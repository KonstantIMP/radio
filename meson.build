project('radio', ['c', 'd'])

gnome = import('gnome')

gtkd_dep = dependency('gtk-d:gtkd', method : 'dub')
gtk_dep = dependency('gtk+-3.0')

source_root = meson.source_root()
sources_dir = include_directories('source/')

resources_dir = 'resource/'

radio_sources = [
    'source/app.d',
    'source/RadioWin.d',
    'source/Plot.d',
    'source/VideoPulsePlot.d',
    'source/ModulationType.d',
    'source/RadioPulsePlot.d',
    'source/NoiseRadioPulsePlot.d'
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