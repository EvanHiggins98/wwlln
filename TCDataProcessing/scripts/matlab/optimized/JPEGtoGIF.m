clear;

JPEGtoGIFheader;

[n, m] = size(jpegInputFiles);

for i = 1:n
im = imread(char(jpegInputFiles(i)));
[A,map] = rgb2ind(im,256);
	if i == 1
		imwrite(A,map,gifOutputFilename,'gif','LoopCount',Inf,'DelayTime',1);
	else
		imwrite(A,map,gifOutputFilename,'gif','WriteMode','append','DelayTime',1);
	end
end
