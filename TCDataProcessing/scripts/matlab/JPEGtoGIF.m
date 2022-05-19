function = JPEGtoGIF(output_path__,output_name_pattern__,product_name__)
	clear;

	%JPEGtoGIFheader;
	%ScriptHeader;

	cd(output_path__);
	%cd(output_instances_list__('path'));

	gifOutputFilename = sprintf(output_name_pattern__, [product_name__, '.gif']);

	files = dir('*.jpg');
	[n, m] = size(files);

	for i = 1:n
	im = imread(char(files(i).name));
	[A,map] = rgb2ind(im,256);
		if i == 1
			imwrite(A,map,gifOutputFilename,'gif','LoopCount',Inf,'DelayTime',1);
		else
			imwrite(A,map,gifOutputFilename,'gif','WriteMode','append','DelayTime',1);
		end
	end
end
