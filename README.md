Stream Processing on a Multi-core DSP with Open Event Machine
=============================================================

Abstract
--------
Streaming data is responsible for a large fraction of the growth in creation and copying of data over the Internet. Video streams make up a sizable portion of this data. Stream processing is a computing paradigm that seeks to provide a useful abstraction of computing over streaming data. The stream processing and signal processing models are similar on a high level.

Digital Signal Processors (DSP) are computing units optimized for low energy consumption in signal processing tasks. The trend toward more cores in CPUs and GPUs has been adopted by the DSP vendors as well. Multi-core DSPs provide an interesting platform for stream processing as they combine an architecture optimized for signal processing tasks with the parallel computing power of the multiple cores.

Scheduling parallel computing is a non-trivial task. On DSPs it is often complicated by the lack of an OS as an abstraction layer for parallelism. Open Event Machine (OpenEM) provides a task-parallel computing model for Texas Instruments (TI) multi-core DSPs with a dynamic, hardware accelerated scheduler. In this thesis the performance of OpenEM in stream processing is investigated. The TI implementation of OpenEM for TMS320C6678 multi-core DSP is used in this thesis.

The concrete contributions of this thesis are the construction of an OpenEM based video stream processing measurement system, the construction of similar, statically scheduled measurement system, the comparison of the systems and the analysis of the stream processing performance of OpenEM using the measurement systems. The analysis uses the results of three experiments conducted in this thesis.

The results of the experiments show that the OpenEM runtime can be used for implementing high performance stream processing applications. Further research is needed to compare the performance to the competing computing platforms.

