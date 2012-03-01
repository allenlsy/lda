% 0. Initialization
pkg load image
pkg load strings


% 1. Face Image Cropping and Preprocessing



% 2. Construct ImageDB: Read Images
cd dataset;
folder = dir('.')
for i=1:40
    folderName = folder(i+3).name;
    subdir = dir( folderName );
    for j=1:10
        index = (i-1)*10+j
        imageDb(index).label = i;
        imageDb(index).image = imread( strcat( folderName, '/', subdir(j+2).name ) );
    end

end
save -binary imageDb.data imageDb


% 3. Construct FeatureDB: Extract Features
imageDb


% 4. Dimensionality Reduction: PCA




% 5. Construct FaceDB: Project Data to low-dimensional space



% 6. Classification: Nearest Neighbor
