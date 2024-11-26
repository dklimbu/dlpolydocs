Introduction
============

.. _intro:

**DLPOLY Quantum** is a general purpose package for performing path integral-based dynamics simultions of condensed-phase systems.

1. PIMD
-------

The PIMD Hamiltonian for `n-beads` replica with `N` atoms system is defined as

.. math::
   H_n(\mathbf{x},\mathbf{p}) = \sum_{i=1}^N\sum_{\alpha=1}^{n} \left[ \frac{p_{i,\alpha}^2}{2m_i^{'}} +
	\frac{1}{2}m_i\omega_n^2 \left( x_{i,\alpha}-x_{i,\alpha-1} \right)^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(x_{1,\alpha},\dots,x_{N,\alpha}),

where :math:`x_{i,\alpha}` and :math:`p_{i,\alpha}` are the position and momentum of the :math:`\alpha`-th bead of the `i`-th particle, :math:`m_i^{'}` is the fictitious Parrinello-Rahman mass, and :math:`\omega_n= \frac{\sqrt{n}}{\beta\hbar}`.

The equations of motion (EOMs) derived from the PIMD Hamiltonian are:

.. math::
   \dot{p}_{i,\alpha} &= -m_i \omega_n^2 (2x_{i,\alpha} - x_{i,\alpha-1} - x_{i,\alpha+1}) + \frac{1}{n} \nabla_{x_{i,\alpha}}V( \mathbf{x} ) \\
   \dot{x}_{i,\alpha} &= \frac{p_{i,\alpha}}{m_i^{'}}.

.. note::
   To ensure that the configurations sampled during the trajectories are part of the correct Boltzmann distribution, PIMD simulations are performed in the canonical ensemble by coupling the dynamics to a thermostat.

.. warning::
   Straightforward implementation of the PIMD Hamiltonian and its EOMs in Cartesian coordinates is complicated by the harmonic coupling between neighboring beads. Most implementations of the method transform the Hamiltonian into a different coordinate system which diagonalizes the couplings, like staging variables or normal mode coordinate.

PIMD Hamiltonian in normal modes is

.. math::
   H_{\mathrm{NM}} = \sum_{i=1}^N\sum_{k=0}^{n-1}\left[ \frac{\pi_{i,k}^2}{2m_{i}} + \frac{1}{2}m_{i} \omega_k^2 q_{i,k}^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(x_{1,\alpha}(\mathbf{q}),\dots,x_{N,\alpha}(\mathbf{q}))

where :math:`\omega_k = 2\omega_n\sin(k\pi/n)` are normal mode frequencies and :math:`q_{i,k}` and :math:`\pi_{i,k}` are the positions and momenta for the `k`-th normal mode of the `i`-th atom.

2. RPMD
-------

The RPMD Hamiltonian is

.. math::
   H_n(\mathbf{x},\mathbf{p}) = \sum_{i=1}^N\sum_{\alpha=1}^{n}\left[ \frac{p_{i,\alpha}^2}{2m^{(i)}_{n}} + \frac{1}{2}m^{(i)}_{n}\omega_n^2 \left( x_{i,\alpha}-x_{i,\alpha-1} \right)^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(x_{1,\alpha},\dots,x_{N,\alpha}),

with :math:`m_n^{(i)}=\frac{m_i}{n}` and :math:`\omega_n= \frac{n}{\beta\hbar}`. 

.. note::
  The fictitious mass in the kinetic energy term must be equal to the physical mass, with the additional factor of :math:`\frac{1}{n}` multiplying the physical mass coming from sampling the initial momenta at the physical temperature, :math:`\beta`, instead of a higher temperature, :math:`\beta_n= \frac{\beta}{n}`, as is often done in RPMD simulations.

3. T-RPMD
---------

The T-RPMD Hamiltonian is

.. math::
   H_n(\mathbf{x},\mathbf{p}) = \sum_{i=1}^N\sum_{\alpha=1}^{n}\left[ \frac{p_{i,\alpha}^2}{2m^{(i)}_{n}} + \frac{1}{2}m^{(i)}_{n}\omega_n^2 \left( x_{i,\alpha}-x_{i,\alpha-1} \right)^2\right] + \frac{1}{n}\sum_{\alpha=1}^{n}V(x_{1,\alpha},\dots,x_{N,\alpha}),

with :math:`m_n^{(i)}=\frac{m_i}{n}` and :math:`\omega_n= \frac{n}{\beta\hbar}`. 

.. note::
   The T-RPMD can be considered as an intermediate method between RPMD and CMD which ``couples the internal modes of the RP to a thermostat without altering their masses``. This helps to remove the spurious frequencies from standard RPMD without the curvature problem of CMD. The T-RPMD Hamiltonian is the same as that for standard RPMD where the internal modes are coupled to the PILE thermostat while the centroid is not thermostatted.

4. PA-CMD
---------

The PA-CMD effective Hamiltonian in terms of the free ring polymer normal modes is:

.. math::

   H_{\mathrm{PA-CMD}}^0=\sum_{i=1}^{N}\sum_{k=0}^{n-1}
  \left[ \frac{\tilde{p}_{i,k}^2}{2\sigma_k^2m_n^{(i)}} + \frac{1}{2}m_n^{(i)}\omega_k^2\tilde{q}_{i,k}^2\right]

where, :math:`\sigma_k` is a scaling factor defined as

.. math::
   \sigma_k =\begin{cases}
   1, \quad k=0 \\
   \omega_k/\Omega, \quad k\neq0
   \end{cases}

.. note::
   The choice of :math:`\Omega`, related to the adiabaticity parameter of the original PA-CMD, determines how adiabatically separated the centroid is from the other internal modes. One such choice is :math:`\Omega = \frac{n^{n/(n-1)}}{\beta\hbar}`

5. f-CMD
--------

6. f-QCMD
---------

7. h-CMD
--------
