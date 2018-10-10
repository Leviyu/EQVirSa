<div align="center">
  <img src="https://github.com/Leviyu/EQTime/blob/master/image/header.png"><br><br>
</div>

# EQVirSa



EQVirSa is a dissertation project that implement stacking method to enhance signal-to-noise ratio of seismic phases, especially for multiple bounce phases. This project partially contribute to my disseration.

This package is designed to deploy large-scale numerical calculations, mostly time-series data processing. Most of the package are written in C++. A multiprocessing functationality is available in the configuration to maximize the computation power depending on the processes you have.


## Getting Started

### Prerequisites

```
* SAC,        Seismic Analysis Code
* GMT-4.*     Generic Mapping Tools
* TauP-2.1+   Flexible Seismic Travel-Time and Raypath Utilities
```

## Deployment

The package is wrapped up by a shell interface, configuration parameter can be changed in `INFILE`.

To execute the experiment, simply run:
```
./mother.sh number_of_processes
```

The log files are stored under `LOG/` for debugging purpose.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


