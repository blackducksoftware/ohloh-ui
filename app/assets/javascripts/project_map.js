var ProjectMap = {
  init: function(project_param, totalUsers, totalContributors) {
    document.mapParams = { project_param: project_param, totalUsers: totalUsers, totalContributors: totalContributors };
    ProjectMap.getContributors();
  },
  getStacks: function() {
    $('#a_users').unbind('change');
    $('#a_contributors').unbind('change');
    $('#a_users').attr('checked',true);

    Map.clearMarkers();
    $('#map_status').innerHTML='Loading users...';
    Map.defaultIconImage='/assets/map/map_gray.png';
    Map.url='/p/' + document.mapParams['project_param'] + '/stacks/near';
    Map.onComplete=function(jsonData){
      if(jsonData && jsonData.accounts && jsonData.accounts.length > 0){
        uri = '/p/' + document.mapParams['project_param'] + '/users';
        if (document.mapParams['totalUsers'] == 1) {
          link = '<a href="' + uri + '">1 user</a>';
        } else {
          link = '<a href="' + uri + '">' + document.mapParams['totalUsers'] + ' users</a>';
        }
        $('#map_status').html('Showing ' + jsonData.accounts.length + ' of ' + link + '.');
      }else{
        $('#map_status').html('No users located.');
      }
      $('#a_contributors').bind('change',ProjectMap.getContributors);
    };
    Map.getMarkers();
    return false;
  },
  getContributors: function() {
    $('#a_users').unbind('change');
    $('#a_contributors').unbind('change');
    $('#a_contributors').attr('checked',true);

    Map.clearMarkers();
    $('#map_status').innerHTML='Loading contributors...';
    Map.defaultIconImage='/assets/map/map_yellow.png';
    Map.url='/p/' + document.mapParams['project_param'] + '/contributors/near';
    Map.onComplete=function(jsonData){
      if(jsonData && jsonData.accounts && jsonData.accounts.length > 0){
        if (document.mapParams['totalContributors'] == null) {
          link = ' contributor(s).';
        } else {
          uri = '/p/' + document.mapParams['project_param'] + '/contributors';
          link = '<a href="' + uri + '">' + document.mapParams['totalContributors'] + ' contributor(s).</a>';
        }
        $('#map_status').html('Showing ' + jsonData.accounts.length + ' of ' + link);
      }else{
        $('#map_status').html('No contributors located.');
      }
      $('#a_users').bind('change', ProjectMap.getStacks);
    };
    Map.getMarkers();
    return false;
  }
}
