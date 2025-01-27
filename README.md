# DLM
Building a DLM model for time series data


# What is a DLM?

A Dynamic Linear Model (DLM) is a time series model that governs the progression of the variable of interest using a heirarchical structure. We first assume the process is governed by some hidden underlying structure (the state equation), and then determine how we have obtained the oberved data from the state of the system (the observation equation). The model is heirarchical since the observation variables are determined by the underlying state variables. 

Calculation of these two states is often done using matrix multiplication and addition. We first set a parameter $\theta$ that contains information about the state at that particulat time. For example in my model, I assume the underlying process is governed by a third order polynomial plus some seasonal trend every 7 time points. $\theta_t$ is the dummy variable that will encode the relevant seasonal and polynomial information at a given time point t.

