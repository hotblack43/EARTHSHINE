PROGRAM FITS_CUBE_BUILDER
  USE CFITSIO
  IMPLICIT NONE

  ! Declare variables
  CHARACTER(LEN=100) :: filenames(4), output_file
  INTEGER :: naxis, status, i
  INTEGER, DIMENSION(3) :: naxes
  INTEGER*8 :: nelements
  REAL, ALLOCATABLE, DIMENSION(:,:,:) :: fits_cube
  REAL, ALLOCATABLE, DIMENSION(:,:) :: incidence_map, emission_map, azimuth_map

  ! Define input FITS files
  filenames(1) = "./OUTPUT/IDEAL/ideal_LunarImg_SCA_0p34577230_JD_2455864.7415237_illfrac_0.1608.fit"
  filenames(2) = "./OUTPUT/LONLAT_AND_ANGLES_IMAGES/lonlatSELimage_JD2455864.7415237.fits"
  filenames(3) = "./OUTPUT/LONLAT_AND_ANGLES_IMAGES/Angles_JD2455864.7415237.fits"
  filenames(4) = "./OUTPUT/SUNMASK/SunMask_JD_2455864.7415237.fit"

  output_file = "fits_cube.fits"

  ! Read first FITS file to determine dimensions
  CALL get_fits_size(filenames(1), naxes)
  nelements = INT(naxes(1)) * INT(naxes(2)) * 4

  ! Allocate memory for FITS cube
  ALLOCATE(fits_cube(naxes(1), naxes(2), 4), STAT=status)
  IF (status /= 0) STOP "Error allocating memory for FITS cube"

  ! Read and stack FITS images
  DO i = 1, 4
    CALL read_fits(filenames(i), fits_cube(:,:,i))
  END DO

  ! Compute azimuthal angle
  ALLOCATE(incidence_map(naxes(1), naxes(2)))
  ALLOCATE(emission_map(naxes(1), naxes(2)))
  ALLOCATE(azimuth_map(naxes(1), naxes(2)))

  CALL compute_azimuthal_angle(fits_cube(:,:,2), fits_cube(:,:,3), 30.0, azimuth_map)

  ! Append azimuthal angle to FITS cube
  CALL write_fits(output_file, fits_cube, azimuth_map, naxes)

  ! Deallocate memory
  DEALLOCATE(fits_cube, incidence_map, emission_map, azimuth_map)

  PRINT *, "FITS cube with azimuthal angle saved successfully."

CONTAINS

  ! ---- Read FITS Image Size ----
  SUBROUTINE get_fits_size(filename, naxes)
    CHARACTER(LEN=100), INTENT(IN) :: filename
    INTEGER, DIMENSION(3), INTENT(OUT) :: naxes
    INTEGER :: status, hdutype
    INTEGER*8 :: fptr

    status = 0
    CALL ftopen(fptr, filename, 0, status)
    CALL ftmahd(fptr, 1, hdutype, status)
    CALL ftgknj(fptr, "NAXIS", 3, naxes, status)
    CALL ftclos(fptr, status)
  END SUBROUTINE get_fits_size

  ! ---- Read FITS Image Data ----
  SUBROUTINE read_fits(filename, image)
    CHARACTER(LEN=100), INTENT(IN) :: filename
    REAL, DIMENSION(:,:), INTENT(OUT) :: image
    INTEGER :: status, hdutype
    INTEGER*8 :: fptr
    INTEGER*8 :: fpixel, nelements

    status = 0
    fpixel = 1
    nelements = SIZE(image)

    CALL ftopen(fptr, filename, 0, status)
    CALL ftmahd(fptr, 1, hdutype, status)
    CALL ftgpve(fptr, 1, fpixel, nelements, 0.0, image, status)
    CALL ftclos(fptr, status)
  END SUBROUTINE read_fits

  ! ---- Compute Azimuthal Angle ----
  SUBROUTINE compute_azimuthal_angle(incidence, emission, phase_angle, azimuth)
    REAL, DIMENSION(:,:), INTENT(IN) :: incidence, emission
    REAL, INTENT(IN) :: phase_angle
    REAL, DIMENSION(:,:), INTENT(OUT) :: azimuth
    INTEGER :: i, j
    REAL :: i_rad, e_rad, alpha_rad, denom, cos_phi

    alpha_rad = phase_angle * 3.14159265358979 / 180.0  ! Convert to radians

    DO i = 1, SIZE(incidence, 1)
      DO j = 1, SIZE(incidence, 2)
        i_rad = incidence(i, j) * 3.14159265358979 / 180.0
        e_rad = emission(i, j) * 3.14159265358979 / 180.0
        denom = SIN(i_rad) * SIN(e_rad)
        IF (denom == 0) THEN
          azimuth(i, j) = -999
        ELSE
          cos_phi = (COS(alpha_rad) - COS(i_rad) * COS(e_rad)) / denom
          cos_phi = MAX(-1.0, MIN(1.0, cos_phi))  ! Clip values
          azimuth(i, j) = ACOS(cos_phi)
        END IF
      END DO
    END DO
  END SUBROUTINE compute_azimuthal_angle

  ! ---- Write FITS Cube ----
  SUBROUTINE write_fits(filename, data, azimuth, naxes)
    CHARACTER(LEN=100), INTENT(IN) :: filename
    REAL, DIMENSION(:,:,:), INTENT(IN) :: data
    REAL, DIMENSION(:,:), INTENT(IN) :: azimuth
    INTEGER, DIMENSION(3), INTENT(IN) :: naxes
    INTEGER :: status, bitpix, naxis
    INTEGER*8 :: fptr
    INTEGER*8 :: fpixel, nelements

    status = 0
    bitpix = -32  ! Floating point
    naxis = 3
    nelements = SIZE(data) + SIZE(azimuth)

    CALL ftinit(fptr, filename, 0, status)
    CALL ftphpr(fptr, bitpix, naxis, naxes, 0, 0, 0, .FALSE., status)
    
    fpixel = 1
    CALL ftppve(fptr, 1, fpixel, SIZE(data), data, status)
    CALL ftppve(fptr, 1, fpixel + SIZE(data), SIZE(azimuth), azimuth, status)

    CALL ftpkyt(fptr, "COMMENT", "Azimuthal angle added", status)
    CALL ftclos(fptr, status)
  END SUBROUTINE write_fits

END PROGRAM FITS_CUBE_BUILDER

