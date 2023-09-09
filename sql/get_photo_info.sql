with 
adobe_tbl as (
    select 
       id_local ,
        masterImage ,
        rootFile ,
        captureTime ,
        fileFormat ,
        fileHeight ,
        fileWidth ,
        aspectRatioCache ,
        orientation ,
        originalCaptureTime ,
        originalRootEntity ,
        panningDistanceH ,
        panningDistanceV ,
        rating ,
        colorLabels,
        touchCount ,
        touchTime
    from Adobe_images 
),
file_tbl as (
    select 
        fi.id_local,
        fi.idx_filename,
        fi.baseName,
        fi.extension,
        fi.originalFilename,
        fi.modTime,
        fi.externalModTime,
        fo.pathFromRoot,
        rfo.absolutePath as rootFolder
    from AgLibraryFile fi
    left join AgLibraryFolder fo
    on fi.folder=fo.id_local
    left join AgLibraryRootFolder rfo
    on fo.rootFolder=rfo.id_local
),
exif_tbl as (
    select 
        exif.image,
        exif.dateYear,
        exif.dateMonth,
        exif.dateDay,    
        exif.focalLength,
        exif.aperture,
        exif.isoSpeedRating,
        exif.shutterSpeed,
        exif.gpsLatitude,
        exif.gpsLongitude,
        exif.gpsSequence,
        exif.hasGPS,
        cmdl.value as cameraModel,
        lns.value as lens
    from AgHarvestedExifMetaData exif
        left join AgInternedExifCameraModel cmdl
            on exif.cameraModelRef=cmdl.id_local
        left join AgInternedExifLens lns
            on exif.lensRef=lns.id_local
),
iptc_tbl as (
    select 
        iptc.image,
        cntry.value as country,
        stt.value as state,
        cty.value as city,
        lctn.value as location,
        iptc.locationDataOrigination,
        iptc.locationGPSSequence    
    from AgHarvestedIptcMetadata iptc
        left join AgInternedIptcCountry cntry
            on iptc.countryRef=cntry.id_local
        left join AgInternedIptcState stt
            on iptc.stateRef=stt.id_local
        left join AgInternedIptcCity cty
            on iptc.cityRef=cty.id_local
        left join AgInternedIptcLocation lctn
            on iptc.locationRef=lctn.id_local
)
select 
    a.id_local,
    masterImage ,
    rootFile ,
    captureTime ,
    fileFormat ,
    fileHeight ,
    fileWidth ,
    aspectRatioCache ,
    orientation ,
    originalCaptureTime ,
    originalRootEntity ,
    panningDistanceH ,
    panningDistanceV ,
    rating ,
    colorLabels,
    touchCount ,
    touchTime,
    idx_filename,
    baseName,
    extension,
    originalFilename,
    modTime,
    externalModTime,
    pathFromRoot,
    rootFolder,
    dateYear,
    dateMonth,
    dateDay,    
    focalLength,
    aperture,
    CASE 
        WHEN ROUND(POWER(2, aperture/2), 1) * 10 % 10 = 0
        THEN 'F' || CAST(CAST(ROUND(POWER(2, aperture/2), 0) AS INTEGER) AS TEXT)
        ELSE 'F' || CAST(ROUND(POWER(2, aperture/2), 1) AS TEXT)
    END AS fNumber,
    isoSpeedRating,
    shutterSpeed,
    CASE 
        WHEN POWER(2, shutterSpeed) > 1 
        THEN '1/' || CAST(CAST(ROUND(POWER(2, shutterSpeed), 0) AS INTEGER) AS TEXT)
        ELSE CAST(CAST(ROUND(1 / POWER(2, shutterSpeed), 0) AS INTEGER) AS TEXT)
    END AS exposureTime,
    gpsLatitude,
    gpsLongitude,
    gpsSequence,
    hasGPS,
    cameraModel,
    lens,
    country,
    state,
    city,
    location,
    locationDataOrigination,
    locationGPSSequence
from adobe_tbl a
    left join file_tbl f on a.rootFile=f.id_local
    left join exif_tbl e on a.id_local=e.image
    left join iptc_tbl i on a.id_local=i.image
;