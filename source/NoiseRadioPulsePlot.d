// NoiseRadioPulsePlot module define
module NoiseRadioPulsePlot;

// Import parent class
import RadioPulsePlot;

// Import libraries for noise calculating
import std.math, std.random;

// Import basic plot class
import Plot;

// NoiseRadioPulsePlot class
class NoiseRadioPulsePlot : RadioPulsePlot {
    // @brief NoiseRadioPlot constructor
    // Init parent's class and set params
    public this () { super();
        // Set another plot name
        this.setPlotName("Полученный радиосигнал");
    
        // Set default noise value
        noise = 25;
    }

    // @brief Create array of point coordinates
    // Create sinusoidal signal with freq, modulate it and sum with noise
    override protected float [] createYS () {
        // Get basic signal YS array
        float [] ys = super.createYS();

        // Calculate noise amplitude
        float noise_amp = 2.0 / (pow(10.0, (noise / 20.0)));

        // Variables for Box-Muller transform
        float r = 0.0, q = 0.0;

        // Sum noise and signal
        for (ulong i = 0; i < ys.length; i++) {
            r = uniform!"(]"(0.0f, 1.0f); q = uniform!"(]"(0.0f, 1.0f);
            ys[i] = ys[i] + noise_amp * (cos(PI2 * q) * sqrt((-2) * log(r)));
        }

        return ys;
    }

    // @brief setNoise Setter for noise
    public void setNoise (float noise_value) {
        noise = noise_value;
    }

    // Signal's noise power
    protected float noise;
}