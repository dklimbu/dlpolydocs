Introduction
============

.. _intro:

**DLPOLY Quantum** is a general purpose package for performing path integral-based dynamics simultions of condensed-phase systems.

1. PIMD
-------

The PIMD [#pimd]_ Hamiltonian for `n-beads` replica with `N` atoms system is defined as

.. math::
   H_n(\mathbf{q},\mathbf{p}) = \sum_{i=1}^N\sum_{\alpha=1}^{n} \left[ \frac{p_{i,\alpha}^2}{2m_i^{'}} + \frac{1}{2}m_i\omega_n^2 \left( q_{i,\alpha}-q_{i,\alpha-1} \right)^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(q_{1,\alpha},\dots,q_{N,\alpha}),
     
where :math:`q_{i,\alpha}` and :math:`p_{i,\alpha}` are the position and momentum of the :math:`\alpha`-th bead of the `i`-th particle, :math:`m_i^{'}` is the fictitious Parrinello-Rahman mass, and :math:`\omega_n= \frac{\sqrt{n}}{\beta\hbar}`.

The equations of motion (EOMs) derived from the PIMD Hamiltonian are:

.. math::
   \dot{p}_{i,\alpha} &= -m_i \omega_n^2 (2q_{i,\alpha} - q_{i,\alpha-1} - q_{i,\alpha+1}) + \frac{1}{n} \nabla_{q_{i,\alpha}}V( \mathbf{q} ) \\
   \dot{q}_{i,\alpha} &= \frac{p_{i,\alpha}}{m_i^{'}}.

.. note::
   To ensure that the configurations sampled during the trajectories are part of the correct Boltzmann distribution, PIMD simulations are performed in the canonical ensemble by coupling the dynamics to a thermostat.

.. warning::
   Straightforward implementation of the PIMD Hamiltonian and its EOMs in Cartesian coordinates is complicated by the harmonic coupling between neighboring beads. Most implementations of the method transform the Hamiltonian into a different coordinate system which diagonalizes the couplings, like staging variables or normal mode coordinate.

PIMD Hamiltonian in normal modes is

.. math::
   H_{\mathrm{NM}} = \sum_{i=1}^N\sum_{k=0}^{n-1}\left[ \frac{\tilde{p}_{i,k}^2}{2m_{i}^{'}} + \frac{1}{2}m_{i} \omega_k^2 \tilde{q}_{i,k}^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(q_{1,\alpha}(\mathbf{\tilde{q}}),\dots,q_{N,\alpha}(\mathbf{\tilde{q}}))

where :math:`\omega_k = 2\omega_n\sin(k\pi/n)` are normal mode frequencies and :math:`\tilde{q}_{i,k}` and :math:`\tilde{p}i_{i,k}` are the normal mode positions and momenta for the `k`-th normal mode of the `i`-th atom.

.. note::
   The transformation matrix for ring polymer normal modes are:

   .. math::
      C_{\alpha k} = 
	\begin{cases}
	\sqrt{1/n} & k = 0\\
	\sqrt{2/n}\cos(2\pi \alpha k/n) & 1 \leq k \leq n/2 - 1\\
	\sqrt{1/n}(-1)^\alpha & k = n/2 \\
	\sqrt{2/n}\sin(2\pi \alpha k/n) & n/2 + 1 \leq k \leq n-1 
	\end{cases}

**The Velocity-Verlet algorithm steps for ring polymer normal mode:**

- The normal mode momenta at first half a time step:

.. math::
   \tilde{p}_{i,k} \leftarrow \tilde{p}_{i,k} - \frac{\Delta t}{2}\frac{\partial V}{\partial \tilde{q}_{i,k}}

- The free ring polymer evolution of the normal mode positions and momenta:

.. math::
   &\begin{pmatrix}
	\tilde{p}_{i,k} \\
	\tilde{q}_{i,k}
   \end{pmatrix} \leftarrow
   &\begin{pmatrix}
	\cos(\omega_k\Delta t) & -{m_i}\omega_k\sin(\omega_k\Delta t) \\
	(m_i\omega_k)^{-1}\sin(\omega_k\Delta t) & \cos(\omega_k\Delta t)
   \end{pmatrix}
   \begin{pmatrix}
	\tilde{p}_{i,k} \\
	\tilde{q}_{i,k}
   \end{pmatrix}.

- The normal mode momenta at second half a time step:

.. math::
   \tilde{p}_{i,k} \leftarrow \tilde{p}_{i,k} - \frac{\Delta t}{2}\frac{\partial V}{\partial \tilde{q}_{i,k}}

.. note::
   In between **free ring polymer** and **second half time step  mementa** calculation , the forces from the external potential are calculated based on the **Cartesian positions** and then converted into the normal mode basis, to reduce the overall number of transformations needed to be performed. 

   .. math::
      \frac{\partial V}{\partial \tilde{q}_{i,k}} = \sum_{\alpha=1}^n C_{\alpha k}\frac{\partial V}{\partial q_{i,\alpha}}.


2. RPMD
-------

The RPMD [#rpmd]_ Hamiltonian is

.. math::
   H_n(\mathbf{q},\mathbf{p}) = \sum_{i=1}^N\sum_{\alpha=1}^{n}\left[ \frac{p_{i,\alpha}^2}{2m^{(i)}_{n}} + \frac{1}{2}m^{(i)}_{n}\omega_n^2 \left( q_{i,\alpha}-q_{i,\alpha-1} \right)^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(q_{1,\alpha},\dots,q_{N,\alpha}),

with :math:`m_n^{(i)}=\frac{m_i}{n}` and :math:`\omega_n= \frac{n}{\beta\hbar}`. 

.. note::
  The fictitious mass in the kinetic energy term must be equal to the physical mass, with the additional factor of :math:`\frac{1}{n}` multiplying the physical mass coming from sampling the initial momenta at the physical temperature, :math:`\beta`, instead of a higher temperature, :math:`\beta_n= \frac{\beta}{n}`, as is often done in RPMD simulations.

3. T-RPMD
---------
Thermostatted RPMD (T-RPMD) [#trpmd]_ was introduced as a method to calculate vibrational spectra using RPMD while avoiding the resonance problem. This approach incorporates thermostats into the dynamics, effectively mitigating spurious peaks that arise in standard RPMD simulations.

``T-RPMD Hamiltonian is the same as that for standard RPMD`` 


.. note::
   In T-RPMD, the internal modes of the ring polymer are thermostatted using the PILE thermostat. The centroid, however, is allowed to evolve freely without the influence of a thermostat. This separation ensures that the internal modes are regulated while preserving the dynamics of the centroid, which is essential for capturing vibrational features.
    
4. PA-CMD
---------

The PA-CMD [#pacmd]_ effective Hamiltonian in terms of the free ring polymer normal modes is:

.. math::

   H_{\mathrm{PA-CMD}}=\sum_{i=1}^{N}\sum_{k=0}^{n-1}
  \left[ \frac{\tilde{p}_{i,k}^2}{2\sigma_k^2m_n^{(i)}} + \frac{1}{2}m_n^{(i)}\omega_k^2\tilde{q}_{i,k}^2\right]

where, :math:`\sigma_k` is a scaling factor defined as

.. math::
   \sigma_k =\begin{cases}
   1, \quad k=0 \\
   \omega_k/\Omega, \quad k\neq0
   \end{cases}

.. note::
   The choice of :math:`\Omega`, related to the adiabaticity parameter of the original PA-CMD, determines how adiabatically separated the centroid is from the other internal modes. One such choice is

   .. math::
      \Omega = \frac{n^{n/(n-1)}}{\beta\hbar}


5. f-QCMD
---------
f-QCMD [#fqcmd]_, inspired by the fast implementation of CMD, uses
PIMD simulations as a reference to construct a corrective potential that
mimics the effective mean-field potential from adiabatic-QCMD [#qcmd]_. This effective potential has the form:

.. math::
   V_{\mathrm{qc}}(\mathbf{r}) = V_{\mathrm{cl}}(\mathbf{r}) + \Delta V_{\mathrm{intra}}(\mathbf{r}) + \Delta V_{\mathrm{inter}}(\mathbf{r}),

where :math:`V_{\mathrm{cl}}(\mathbf{r})` is the base, classical potential, and :math:`\Delta V_{\mathrm{intra}}(\mathbf{r})`
and :math:`\Delta V_{\mathrm{inter}}(\mathbf{r})` are the correction terms for intra- and inter-molecular interactions, respectively.
The correction potentials are determined using the iterative Boltzmann inversion (IBI) method [#ibi_Reith2003]_ with a set of distribution functions of two types: 
(1) intra-molecular bond and angle distribution functions and 
(2) inter-molecular radial distribution functions (RDFs).

**IBI Process**
^^^^^^^^^^^^^^^
The IBI process involves a series of steps to generate the corrective potentials:

1. **PIMD Reference Simulations:**
   Distributions are obtained from PIMD simulations to serve as a reference for the effective potential.

2. **Iteration Zero:**
   At iteration zero, :math:`\Delta V_{\mathrm{intra}}^{(0)}(\mathbf{r})` and :math:`\Delta V_{\mathrm{inter}}^{(0)}(\mathbf{r})`
   are set to zero, equivalent to classical dynamics under the base potential :math:`V_{\mathrm{cl}}(\mathbf{r})`.

3. **Subsequent Iterations:**
   For each iteration :math:`i`, the distribution functions
   (:math:`\rho_{R}^{(i)}(r)`, :math:`\rho_{\Theta}^{(i)}(\theta)`, and :math:`g_{\mathrm{XY}}^{(i)}(r)`) are calculated as classical averages under the effective potential. The corrections for the next iteration are updated using the equations:

   .. math::
      \begin{split}
      \Delta V_R^{(i+1)}(r) &= \Delta V_R^{(i)}(r) - \frac{1}{\beta} \ln\left( \frac{\rho_R^{\mathrm{exact}}(r)}{\rho_R^{(i)}(r)} \right), \\
      \Delta V_\Theta^{(i+1)}(\theta) &= \Delta V_\Theta^{(i)}(\theta) - \frac{1}{\beta} \ln\left( \frac{\rho_\Theta^{\mathrm{exact}}(\theta)}{\rho_\Theta^{(i)}(\theta)} \right), \\
      \Delta V_{\mathrm{XY}}^{(i+1)}(r) &= \Delta V_{\mathrm{XY}}^{(i)}(r) - \frac{1}{\beta} \ln\left( \frac{g_{\mathrm{XY}}^{\mathrm{exact}}(r)}{g_{\mathrm{XY}}^{(i)}(r)} \right),
      \end{split}

   where :math:`\beta = 1 / k_\mathrm{b}T` and the exact distributions (:math:`\rho_R^{\mathrm{exact}}(r)`,
   :math:`\rho_\Theta^{\mathrm{exact}}(\theta)`, and :math:`g_{\mathrm{XY}}^{\mathrm{exact}}(r)`) are calculated from
   the PIMD simulations using histogram binning.

**Regularized IBI**
^^^^^^^^^^^^^^^^^^^
To address statistical errors in RDFs when values are small, the regularized form of IBI is used to stabilize the process near convergence. [#fqcmd_ice_water]_
The updates to the inter-molecular corrections are modified as:

.. math::
   \Delta V_{\mathrm{XY}}^{(i+1)}(r) = \Delta V_{\mathrm{XY}}^{(i)}(r) - \frac{1}{\beta} \log\left( \frac{g_{\mathrm{XY}}^{\mathrm{exact}}(r) + \varepsilon G_{\mathrm{XY}}}{g_{\mathrm{XY}}^{(i)}(r) + \varepsilon G_{\mathrm{XY}}} \right),

where :math:`\varepsilon` is a positive scalar parameter, and :math:`G_{\mathrm{XY}}` is the maximum value of the RDFs,
allowing the same :math:`\varepsilon` for all RDFs.

.. note::

   Regularization IBI is particularly useful for ensuring stability when the IBI process approaches convergence, as small statistical errors can dominate the iterations.

6. f-CMD
--------
A "fast" version of CMD (f-CMD) [#fcmd_Voth2005]_ was introduced by Voth and coworkers as an effort to reduce the computational cost of CMD over the years. 
This method involves adding a small correction to the classical forcefield to produce a potential consistent 
with the effective mean-field potential of the PI simulations. 

So, the effective potential being replicated in f-CMD originates 
from the RP centroids and the corrective potentials are 
obtained using a force-matching method.

.. note::
   The force-matching procedure, while effective, is less convenient than the IBI methodology used in f-QCMD. It involves solving a single-value decomposition problem for a large number of equations. For example, a system of 216 water molecules generates a set of 1944 equations for atomic forces for each configuration in a trajectory.

**f-CMD with IBI**
^^^^^^^^^^^^^^^^^^

A version of f-CMD was introduced 
where the corrective potentials are obtained using the IBI method. 
This approach follows the same framework as f-QCMD with key differences 
in the definition and calculation of reference distributions:

- The Quasi-Centroid (QC) values are taken as the Cartesian centroids when calculating RDFs.
- For intra-molecular distributions, bond and angle values are determined from polar coordinates of Cartesian centroids instead of bead-averaged values.

.. note::
   The IBI process is used to generate the corrective potentials consistent with the CMD effective mean-field potential. This allows for classical-like simulations with CMD NQEs incorporated.
  
7. h-CMD
--------
While f-QCMD is capable of creating vibrational spectra with accuracy comparable to AQCMD simulations, it faces challenges when applied to complex systems, particularly those containing large, complex molecules or materials. These limitations arise from the application of Eckart-like conditions using a rotation matrix, which requires an initial set of QC coordinates. For large molecules, transitioning from curvilinear coordinates to QCs can be challenging to generalize.

To address this issue and extend f-QCMD to more complex systems, the hybrid CMD (h-CMD) [#hcmd]_ method was introduced. The core idea of h-CMD is to selectively apply the f-QCMD method only to those degrees of freedom that are significantly affected by the curvature problem, while treating the remaining degrees of freedom with f-CMD.

.. note::
   The h-CMD method provides a feasible solution for systems where defining curvilinear coordinates for the entire system is impractical. To ensure consistency, the h-CMD method employs the same form of correction potentials as f-QCMD for f-CMD simulations, with the correction potentials determined using the iterative Boltzmann inversion (IBI) method instead of force matching. The primary difference between f-QCMD and f-CMD calculations within the h-CMD scheme is that the reference distribution functions for f-CMD molecules are derived using Cartesian centroids instead of QCs

.. note::
   The h-CMD method offers:
   
   1. **Flexibility**: Only a subset of degrees of freedom are treated at the f-QCMD level, reducing computational complexity.
   2. **Generalization**: Enables the application of CMD methods to systems where defining QC coordinates for all components is infeasible.
   3. **Accuracy**: Maintains the high accuracy of vibrational spectra for large complex hetergeneous systems.


References
----------
.. [#pimd] Feynman, R. P.; Hibbs, A. R.; Styer, D. F. `Quantum Mechanics and Path Integrals`; Courier Corporation, **2010**
.. [#rpmd] Craig, I. R.; Manolopoulos, D. E. Quantum statistics and classical mechanics: Real time correlation functions from ring polymer molecular dynamics. J. Chem. Phys. **2004**, 121, 3368-3373
.. [#trpmd] Rossi, M.; Ceriotti, M.; Manolopoulos, D. E. How to Remove the Spurious Resonances from Ring Polymer Molecular Dynamics. J. Chem. Phys. **2014**, 140, 234116
.. [#pacmd] Hone, T. D.; Rossky, P. J.; Voth, G. A. A Comparative Study of Imaginary Time Path Integral Based Methods for Quantum Dynamics. J. Chem. Phys. **2006**, 124, 154103
.. [#fqcmd] Fletcher, T.; Zhu, A.; Lawrence, J. E.; Manolopoulos, D. E. Fast Quasi-Centroid Molecular Dynamics. J. Chem. Phys. **2021**,155, 231101
.. [#qcmd] Trenins, G.; Willatt, M. J.; Althorpe, S. C. Path-Integral Dynamics of Water Using Curvilinear Centroids. J. Chem. Phys. **2019**, 151, 054109
.. [#ibi_Reith2003] Reith, D.; Putz, M.; Muller-Plathe, F. Deriving Effective Mesoscale Potentials from Atomistic Simulations. J. Comput. Chem. **2003**, 24, 1624–1636
.. [#fqcmd_ice_water] Lawrence, J. E.; Lieberherr, A. Z.; Fletcher, T.; Manolopoulos, D. E. Fast Quasi-Centroid Molecular Dynamics for Water and Ice. J. Phys. Chem. B **2023**, 127, 9172–9180
.. [#fcmd_Voth2005] Hone, T. D.; Izvekov, S.; Voth, G. A. Fast Centroid Molecular Dynamics: A Force-Matching Approach for the Predetermination of the Effective Centroid Forces. J. Chem. Phys. **2005**,122, 054105
.. [#hcmd] Limbu, D. K.; London, N.; Faruque, M. O.; Momeni, M. R. h-CMD: An Efficient Hybrid Fast Centroid and Quasi-Centroid Molecular Dynamics Method for the Simulation of Vibrational Spectra. **2024**; DOI: 10.48550/arXiv.2411.08065