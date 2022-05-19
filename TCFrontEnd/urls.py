from django.urls import path

from . import views

app_name = 'storms'

urlpatterns = [
    path('', views.index, name='index'),
    path('storm/<season_num>/<region>/<storm_num>/',
        views.view_storm,
        name = 'view_storm/'),
    path('search/', views.search_view, name = 'search_view'),
    path('group/<season_num>/', views.view_storm_group, name='view_storm_group'),
    path('group/<season_num>/<region>/',
        views.view_storm_group,
        name='view_storm_group'),
]