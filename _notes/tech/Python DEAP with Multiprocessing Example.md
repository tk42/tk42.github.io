---
title: Python DEAP with Multiprocessing Example
date: 2022-07-03
tags: Technology, Programming, Genetic Algorithms, Multiprocessing
publish: true
---
Today I’ll let you know some tips for using the DEAP framework with the multiprocessing module.

First of all, the genetic algorithm (GA) which is one of the evolutionary computations can be useful to find an approximate solution for the evaluation function. GA is one of the so powerful searching algorithms that the head shape of the Shinkansen N700 was built considering the fluid dynamics simulation.

![Shinkansen](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*A_KR_I-_elAV4oA_)

To use GA, we can run it on DEAP which is an evolutionary computation framework with python. You can start DEAP immediately by reading the official documentation.

[DEAP documentation — DEAP 1.4.1 documentation](https://deap.readthedocs.io/en/master/index.html?source=post_page-----9c4fa8a8a424--------------------------------)

---
But here are some problems. GA needs many computational resources because in each generation (loop) the algorithm has to evolve a lot of mutated genes (individuals). So we are thinking about running DEAP by multiprocessing and fortunately using multiple processors is officially supported.
[Using Multiple Processors — DEAP 1.4.1 documentation](https://deap.readthedocs.io/en/master/tutorials/basic/part4.html?source=post_page-----9c4fa8a8a424--------------------------------)

For just added a few lines, your codes are run on multiple processors!

```python
import multiprocessing
  
pool = multiprocessing.Pool()  
toolbox.register("map", pool.map)  
  
_# Continue on with the evolutionary algorithm_**pool.close()**
```

It’s quite easy! Let’s try it in my evaluation function…

> Single: 25.8s  
> Multi: 26.3s

WAIT! I’ll find the code is not faster than before the single processor or a little bit slower. WHY?

In fact, as you are googling, you can see the same questions on stackoverflow.com. I doubted DEAP has a bug of multiprocessing but it was not.

So I’ll share some tips for using the DEAP framework with the multiprocessing module.

At first, when using multiprocessing on Windows, to initialize the process, the above lines must always be followed by

```python
if __name__ == “__main__”:
```

to protect the section. and **run it by not the interactive interpreter mode but the command.**

Secondly, do not forget
```python
pool.close()
```

after the evolutional algorithm logic. This will make sure to close all the pools you have started.

Finally, it is the most important and misunderstanding point whether the evaluation functions have CPU overhead quite enough.

In multiprocessing, each process runs on each CPU core without sharing the memory. So it takes some delay that the processes to pass each task. The delay causes CPU overhead (loss time). Therefore we must check if the evaluation function is heavy enough.

[This official example](https://github.com/DEAP/deap/blob/master/examples/ga/onemax_mp.py) of using a multiprocessing module isn’t explained well because the evaluation function is so light that generates CPU overheads.

The following examinational snippets show you how to run it with the multiprocessing module in DEAP. The snippet for single process is below one of multiprocessing.

Multiprocessing 
```python
#!/usr/bin/env python3

import time
import array
import multiprocessing
import random

import numpy

from deap import algorithms
from deap import base
from deap import creator
from deap import tools


creator.create("FitnessMax", base.Fitness, weights=(1.0,))
creator.create("Individual", array.array, typecode="b", fitness=creator.FitnessMax)

toolbox = base.Toolbox()

# Attribute generator
toolbox.register("attr_bool", random.randint, 0, 1)

# Structure initializers
toolbox.register("individual", tools.initRepeat, creator.Individual, toolbox.attr_bool, 100)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)


def eval_heavy_individual(individual):
    time.sleep(0.1)  # create CPU overhead intentionally
    return (sum(individual),)


toolbox.register("evaluate", eval_heavy_individual)
toolbox.register("mate", tools.cxTwoPoint)
toolbox.register("mutate", tools.mutFlipBit, indpb=0.05)
toolbox.register("select", tools.selTournament, tournsize=3)

if __name__ == "__main__":
    random.seed(64)

    # Process Pool
    cpu_count = multiprocessing.cpu_count()
    print(f"CPU count: {cpu_count}")
    pool = multiprocessing.Pool(cpu_count)
    toolbox.register("map", pool.map)

    pop = toolbox.population(n=10)
    hof = tools.HallOfFame(1)
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("avg", numpy.mean)
    stats.register("std", numpy.std)
    stats.register("min", numpy.min)
    stats.register("max", numpy.max)

    algorithms.eaSimple(pop, toolbox, cxpb=0.5, mutpb=0.2, ngen=40, stats=stats, halloffame=hof)

    pool.close()
```

Single processing
```python
#!/usr/bin/env python3
import array
import time
import random

import numpy

from deap import algorithms
from deap import base
from deap import creator
from deap import tools


creator.create("FitnessMax", base.Fitness, weights=(1.0,))
creator.create("Individual", array.array, typecode="b", fitness=creator.FitnessMax)

toolbox = base.Toolbox()

# Attribute generator
toolbox.register("attr_bool", random.randint, 0, 1)

# Structure initializers
toolbox.register("individual", tools.initRepeat, creator.Individual, toolbox.attr_bool, 100)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)


def eval_heavy_individual(individual):
    time.sleep(0.1)  # create CPU overhead intentionally
    return (sum(individual),)


toolbox.register("evaluate", eval_heavy_individual)
toolbox.register("mate", tools.cxTwoPoint)
toolbox.register("mutate", tools.mutFlipBit, indpb=0.05)
toolbox.register("select", tools.selTournament, tournsize=3)

if __name__ == "__main__":
    random.seed(64)

    # Process Pool
    # cpu_count = multiprocessing.cpu_count()
    # pool = multiprocessing.Pool(cpu_count)
    # toolbox.register("map", pool.map)

    pop = toolbox.population(n=10)
    hof = tools.HallOfFame(1)
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("avg", numpy.mean)
    stats.register("std", numpy.std)
    stats.register("min", numpy.min)
    stats.register("max", numpy.max)

    algorithms.eaSimple(pop, toolbox, cxpb=0.5, mutpb=0.2, ngen=40, stats=stats, halloffame=hof)

    # pool.close()
```

And here is the executed time around on my M1 Macbook Pro (2021). (I created a docker image `ga_mp` for this benchmark.)
```bash
$ docker run -it ga_mp ga_sp.py
```
takes 25.8s but on the other hand, the codes on the multiprocessing module 
```bash
$ docker run -it ga_mp ga_mp.py  
CPU count: 8
```

takes **5.9s.** The multiprocess one is not x8 faster than the single one precisely but the multiprocessing on DEAP is working.

When you run DEAP with the multiprocessing module, you’ll have to check if the evaluation function is heavy enough not to cause CPU overheads.

Bye.

References
[Unable to speed up Python DEAP with Multiprocessing - Stack Overflow](https://stackoverflow.com/questions/61902235/unable-to-speed-up-python-deap-with-multiprocessing?source=post_page-----9c4fa8a8a424--------------------------------)

[python - Using multiprocessing in DEAP for genetic programming - Stack Overflow](https://stackoverflow.com/questions/59116521/using-multiprocessing-in-deap-for-genetic-programming/62005838?source=post_page-----9c4fa8a8a424--------------------------------#62005838)

[Python DEAP Multiprocessing example - Stack Overflow](https://stackoverflow.com/questions/61965927/python-deap-multiprocessing-example?source=post_page-----9c4fa8a8a424--------------------------------)

[optimization - python DEAP library Multiple Processors - Stack Overflow](https://stackoverflow.com/questions/60264402/python-deap-library-multiple-processors?source=post_page-----9c4fa8a8a424--------------------------------)

[python - pythonの並列化について - スタック・オーバーフロー](https://ja.stackoverflow.com/questions/21034/python%E3%81%AE%E4%B8%A6%E5%88%97%E5%8C%96%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6?source=post_page-----9c4fa8a8a424--------------------------------)
