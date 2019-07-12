<div align="center">
  <img src="https://github.com/Leviyu/EQVirSa/blob/master/img/EQVirSa.jpg"><br><br>
</div>

# EQVirSa


EQVirSa is a dissertation project that implement stacking method to enhance signal-to-noise ratio of seismic phases, especially for multiple bounce phases. This project partially contribute to my disseration.

This package is designed to deploy large-scale numerical calculations, mostly time-series data processing. Most of the package are written in C++. A multiprocessing functationality is available in the configuration to maximize the computation power depending on the processes you have.


## Getting Started

### Prerequisites

```
* python2
* SAC (>101.6a)
* GMT 4.5 (>5.0 version would not be compatible)
* TauP (>2.4.5)
```

## Deployment

The package is wrapped up by a shell interface, configuration parameter can be changed in `INFILE`. Some of the important parameters to change include:
* CURRENT_DIR: absolute path of package
* ID: a unique identifier of the calculation, which is used to make directory for calculation and plots
* EXISTING_EVENTINFO: which contains the accepted records information, which is collected from Empirical Wavelet processing
* EVENT_STATION_FILE: which contains the eventStation information of all records that you wish to stack

To execute the experiment, simply run:
```
./mother.sh 
```

The log files are stored under `./LOG/` for debugging purpose.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


