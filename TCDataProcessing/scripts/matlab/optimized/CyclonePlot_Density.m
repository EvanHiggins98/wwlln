clear

% ==================================================
StormScriptHeader;
% ==================================================

GridSize = 5;
PlotSize = 600;

stormTrack = load(StormTrack);

storm_year  = stormTrack(:,1);
storm_month = stormTrack(:,2);
storm_day   = stormTrack(:,3);
%storm_hr    = stormTrack(:,4);

%storm_lat = stormTrack(:,5); %lat for storm of interest
%storm_lon = stormTrack(:,6); %lon for storm of interest

%storm_wind     = stormTrack(:,8);
%storm_pressure = stormTrack(:,7);

year_min = storm_year(1,1);
year_max = storm_year(length(storm_year),1);

month_min=storm_month(1,1);
month_max=storm_month(length(storm_month),1);

day_min=storm_day(1,1); %starting day
day_max=storm_day(length(storm_day),1); %ending day

day_year_min=datenum(year_min, month_min, day_min);
day_year_max=datenum(year_max, month_max, day_max);

% open the track-centered lightning
fid = fopen(StormCenteredLightning, 'r');

%data_storm=fscanf(fid,'%g %02g %02g %02g %02g %07.4f %06.4f %06.4f %g %g\n', [10 inf]);
data_storm=fscanf(fid,'%g %g %g %g %g %g %g %g %g %g\n', [10 inf]);
data_storm=data_storm';

% change path to the output file path
cd(OutputPath);

%year_cg_all  = data_storm(:,1);
month_cg_all = data_storm(:,2);
day_cg_all   = data_storm(:,3);
%hr_cg_all    = data_storm(:,4);
%min_cg_all   = data_storm(:,5);
%sec_cg_all   = data_storm(:,6);
%lat_cg_all   = data_storm(:,7);
%long_cg_all  = data_storm(:,8);
distance_EW  = data_storm(:,9);
distance_NS  = data_storm(:,10);
%dist_center  = (distance_EW.^2 + distance_NS.^2).^0.5;

EW_range=-1005:GridSize:1005;
NS_range=-1005:GridSize:1005;
begin = 2;
P = zeros(length(NS_range), (length(EW_range) + 1 - begin));
for day_year = day_year_min:day_year_max %loop over days of interest

    month = datestr(day_year,5);
    day   = datestr(day_year,7);
    year  = datestr(day_year,10);

    day_num=str2num(day);
    month_num=str2num(month);

    k=find( (day_cg_all==day_num) & (month_cg_all==month_num) );


    % %plot WWLLN events in storm centered coordinates for the day
    %figure;

    EW=distance_EW(k);
    NS=distance_NS(k);

    dist_tot=(EW.^2+NS.^2).^(0.5);

    k1=find(dist_tot<=1000);

    EW=EW(k1);
    NS=NS(k1);

    %n_elements=zeros(length(Ipk_range), 1);

    % t=day+hr/24+min/(24*60);
    %
    % t_bin=[floor(t): 1/8 : ceil(max((t)))];

    for i=begin:length(EW_range)

        %n_elements=zeros(length(Ipk_range), 1);
        j=find( (EW >= EW_range(i-1)) & (EW < EW_range(i)) );

        if isempty(j)==0
            n_elements = histc(NS(j),NS_range);
        else
            n_elements=zeros(length(NS_range), 1);
        end

        if size(n_elements,1)==1
            n_elements=n_elements';
        end

        if size(n_elements,1)==1
            P(:,(i - 1)) = n_elements';
        else
            P(:,(i - 1)) = n_elements;
        end
    end

    surf(EW_range(1:length(EW_range)-1),NS_range,log10(P),'EdgeColor','none');
    axis xy; axis tight; colormap(jet); view(0,90);
    %colormap(flipud(jet))
    %colormap(jet)

    grid on

    ch1=colorbar;
    % Graph string
    GraphAxisString = ['log_{10}(strokes / ', num2str(GridSize^2),' km^2 / hr)'];

    set(get(ch1,'YLabel'),'String', GraphAxisString,'FontSize',10);
    %set(get(ch1,'YTickLabel'),[300 250 200 150])
    drawnow;

    %Testing this for Log scale
    caxis([0, 2]);
    hold off;

    xlabel('East-West Distance (km)');
    ylabel('North-South Distance (km)');
%    xlim([-PlotSize PlotSize]);
%    ylim([-PlotSize PlotSize]);
%    axis square

    title([StormName, ' ', datestr(day_year, 'mm/dd/yyyy'),' (Courtesy of WWLLN/UW/NWRA/DigiPen)'])
    filenameBig = [StormFilenamePrefix,num2str(year),'_',month,'_',day, '_density_plot'];

    set(gca,'FontSize',12,'fontWeight','bold')
    set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold')

% uncomment this for figure
%    saveas(gcf,filename6,'fig')


    xlim([-PlotSize PlotSize]);
    ylim([-PlotSize PlotSize]);
    axis square;
    print('-djpeg','-r150', filenameBig);

    if false
        NewPlot = 150;
        xlim([-NewPlot NewPlot]);
        ylim([-NewPlot NewPlot]);
        axis square;
        filenameSmall = [StormFilenamePrefix,'_Script_',num2str(ScriptNumber),'_PlotSize_',num2str(NewPlot),'_GridSize_',num2str(GridSize),'_',num2str(year),'_',month,'_',day];
        print('-djpeg','-r150', filenameSmall);
    end

    % file_save=[storm_name,'_density.txt'];
    % save(file_save,'P','-ascii');

    % plot(distance_EW(k),distance_NS(k),'*','Markersize', 2)
    % xlim([-800 800])
    % ylim([-800 800])
    % daspect([1 1 1])
    % xlabel('E-W distance from center (km)')
    % ylabel('N-S distance from center (km)')
    % title([storm_name,' ',month,'\',day,'\',num2str(year)])
    % filename5=[storm_name,'_',month,'_',day,'_storm_centered_plot'];
    % saveas(gcf,filename5,'fig')
    % print('-dpdf', filename5);
end
clear k;

%display('done');

exit;
