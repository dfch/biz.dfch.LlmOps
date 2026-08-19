NVIDIA WORKING INVENTORY
========================

Host OS:
- Ubuntu 22.04 LTS

Kernel:
- 6.8.0-117-generic

GPU state (updated 2026-08-19T08:04:27Z to match feat-1 Task 0.2 live check):
- nvidia-smi works after reboot
- Detected GPUs: 4 (all 4 now detected; the earlier "3 GPUs / 4th needs
  power cable fix" state below is historical, resolved 2026-08-18)
- Driver Version: 610.57.04
- CUDA Version reported by nvidia-smi: 13.3
- Total VRAM: 384 GB (4x 96 GB)
- Driver type: NVIDIA Open Kernel Module
- GRUB + modprobe fixes applied (see feat-1 Task 0.2); GPU 0 may show
  ollama residency (~43 GB) when a model is loaded, GPUs 1-3 free.

Historical GPU state (superseded — kept for the driver-source lesson below):
- Detected GPUs: 3 (note: 4th GPU required power cable fix)
- Driver Version: 595.71.05
- CUDA Version reported by nvidia-smi: 13.2

Active NVIDIA package source:
- NVIDIA CUDA repository:
  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64

Installed working NVIDIA packages from NVIDIA CUDA repo
(versions below reflect the historical 595.71.05 stack; the live driver is
now 610.57.04 per the GPU state above — re-capture exact package versions
from the Dell box with `dpkg -l | grep nvidia` before relying on them):
- nvidia-dkms-open           595.71.05-1ubuntu1
- nvidia-firmware            595.71.05-1ubuntu1
- nvidia-kernel-common       595.71.05-1ubuntu1
- libnvidia-compute          595.71.05-1ubuntu1
- libnvidia-cfg1             595.71.05-1ubuntu1
- libnvidia-decode           595.71.05-1ubuntu1
- libnvidia-gpucomp          595.71.05-1ubuntu1
- nvidia-persistenced        595.71.05-1ubuntu1

Related NVIDIA/container packages present:
- libnvidia-container-tools  1.19.0-1
- libnvidia-container1       1.19.0-1
- nvidia-container-toolkit   1.19.0-1
- nvidia-container-toolkit-base 1.19.0-1
- nvidia-modprobe            595.71.05-1ubuntu1
- nvidia-settings            595.71.05-1ubuntu1

DKMS status:
- nvidia/595.71.05, 6.8.0-117-generic, x86_64: installed

Kernel modules installed under:
- /lib/modules/6.8.0-117-generic/updates/dkms/

Expected NVIDIA module files:
- nvidia.ko
- nvidia-modeset.ko
- nvidia-drm.ko
- nvidia-uvm.ko
- nvidia-peermem.ko

Secure Boot:
- disabled

Important note:
- The working configuration uses NVIDIA CUDA repo packages for the active driver stack.
- Mixing Ubuntu multiverse NVIDIA packages with NVIDIA CUDA repo packages caused breakage.

Conflicting Ubuntu packages seen earlier and should NOT be mixed into the active stack:
- nvidia-utils-595                 595.71.05-0ubuntu0.22.04.1
- libnvidia-compute-595           595.71.05-0ubuntu0.22.04.1
- nvidia-kernel-common-595        595.71.05-0ubuntu0.22.04.1
- nvidia-firmware-595-595.71.05   595.71.05-0ubuntu0.22.04.1

Pinning file used to prefer NVIDIA CUDA repo packages:
- /etc/apt/preferences.d/nvidia-cuda-pin

Pin file contents:
Package: nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1 libnvidia-decode libnvidia-gpucomp nvidia-persistenced
Pin: origin developer.download.nvidia.com
Pin-Priority: 1001

Validation commands:
- dkms status
- lsmod | grep nvidia
- modinfo -F version nvidia
- nvidia-smi
- lspci -nn | grep -i nvidia