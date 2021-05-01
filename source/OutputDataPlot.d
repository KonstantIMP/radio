// Module define
module OutputDataPlot;

// Input parent class
import NoiseRadioPulsePlot;

// OutputDataPlot class define
class OutputDataPlot : NoiseRadioPulsePlot {
    // Default constructor
    public this () { super();
        // Set another plot name
        this.setPlotName("Выделение полезной нагрузки");

    }
}

