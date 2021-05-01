// Module define
module OutputDataPlot;

// Import supported Modulation Types enum
import ModulationType;

// Input parent class
import NoiseRadioPulsePlot;

// Import math module
import std.math;

// Import basic plot class
import Plot;

// OutputDataPlot class define
class OutputDataPlot : NoiseRadioPulsePlot {
    // Default constructor
    public this () { super();
        // Set another plot name
        this.setPlotName("Выделение полезной нагрузки");
        // Zero values
        output_bits = "";
    }

    // @brief Create array of point coordinates
    // Calculate usefull signal frame from signal with noise
    override protected float [] createYS () {
        // YS array
        float [] ys = super.createYS();

        // Get useless signal
        for (ulong i = 0; i < ys.length; i++) {
            ys[i] = (ys[i] - (sin(PI2 * freq * (i) / FRAMERATE))) * 0.5;
        }

        return ys;
    }

    // Calculated signal
    private string output_bits;
    // @brief getOutputBits getter for output bits
    public string getOutputBits () { return output_bits; }
}

