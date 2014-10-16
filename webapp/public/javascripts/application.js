//OpenLayers.ImgPath = "/ifbl/images/ol-dark/";

var IFBL = {};

IFBL.constants = {};
IFBL.constants.center_of_belgium = new OpenLayers.LonLat(4.49, 50.55);
IFBL.constants.wms_url = "http://localhost:8080/geoserver/wms"; // TODO Remove this one and adapt the code to use next variable instead.
IFBL.constants.wms_real_url = 'http://localhost:8080//geoserver/wms'; 
IFBL.constants.switch_resolution = 100;
IFBL.constants.app_prefix = '/';


IFBL.constants.mylayers = {
  allsquares_original: {label: 'IFBL Original data', name: 'ifbl:areas_with_direct_checklists'},
  allsquares_generalized: {label: 'IFBL 4 generalized', name: 'ifbl:areas_4_derived_from_1'},
  squares_per_species: {label: 'Species', name: 'ifbl:squares_per_species_and_time'},
  large_squares_per_species: {label: 'Species', name: 'ifbl:squares4_per_species_and_time'}
};

IFBL.helpers = {};

IFBL.helpers.equalHeight = function(group) {
	var tallest = 0;
	group.each(function() {
		var thisHeight = $(this).height();
		if(thisHeight > tallest) {
			tallest = thisHeight;
		}
	});
	group.height(tallest);
}

IFBL.current_page = {}; // Placeholder for variables used by the current page, free to use

IFBL.getGeneralizeButton = function() {
    var $gene_button = $('<span id="gene_button"></span>');
    
    //var $gene_button_help_content =$('<p id="gene_help">fsfsfsdf</p>');
    var $gene_button_help = $('<a class="geb" href="#gene_help"><img alt="help" src="' + IFBL.constants.app_prefix + '/images/question.png' + '" /></a>');
    
    $gene_button.append($('<input type="checkbox" checked="checked" id="generalize"/>').click(function() {
        IFBL.current_page.adaptMapToCheckBox(this, IFBL.current_page.map);
    }));
    
    $gene_button.append($('<label for="generalize">Adapt squares to zoom level</label>'))
    $gene_button.append($gene_button_help);
    
    return $gene_button;
};

IFBL.getAddLayersButtons = function(map) {
  var layers = map.layers;
  var i, id, $radio;
  var $r = $('<span id="more_buttons"/>');
  var $layer;
  
  for (i=0; i<layers.length; i++) {
    $layer = $(layers[i]);
    
    if ($layer.data) {
      if ($layer.data('add_to_my_switcher') == true) {
	var id="more_radio_"+i;
	var input_add_attributes = "";
	if(layers[i].getVisibility()) {
	  input_add_attributes = 'checked="checked"';
	}
	
	var $radio = $('<input type="checkbox" id="' + id + '" ' + input_add_attributes + '/><label for="' + id +'">'+ layers[i].name + ' overlay' +'</label>');
	$radio.change(function() {
	  if($(this).is(':checked')) {
	    $layer[0].setVisibility(true);
	    
	    // If layer has a legend, show it
	    if($layer.data('legend_html')) {
	        $layer.data('legend_html').dialog({width: 300});
	    }
	    
	  } else {
	    $layer[0].setVisibility(false);
	    
	    if($layer.data('legend_html')) {
	        $layer.data('legend_html').dialog('close');
	    }
	  }
	});
	
	$r.append($radio); 
	
	
      }
    }
  }
  
  return $r;
  
},



IFBL.getBgSelector = function (map) {
  var base_layers = map.getLayersBy('isBaseLayer', true)
  var $r = $('<span id="buttonset_inner"/>');
  var $radio;
  
  var i;
  for (i=0; i<base_layers.length; i++) {
     var id="bg_radio_"+i;
     
     // Preselect the current layer
     var input_add_attributes = "";
     if (map.baseLayer == base_layers[i]) {
       input_add_attributes = 'checked="checked"';
     }
     
     var $radio = $('<input type="radio" id="' + id + '" name="bgs" value="' + i + '" ' + input_add_attributes + '/><label for="' + id +'">'+ base_layers[i].name +'</label>');
     
     // Handler
     $radio.change(function() {
       var checked_id = $("[name=bgs]:checked").val();
       //console.log(map);
       //console.log(map.layers[checked_id]);
       map.setBaseLayer(map.layers[checked_id]);
     });
     
     $r.append($radio);
     
  }
  
  $(function() {
    $r.buttonset();
  });
  
  return $r;
}

IFBL.getUrlVars = function () {
      var vars = [], hash;
      var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
      for(var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
      }
    return vars;
};

// Also fills the results_container container
IFBL.getAndWriteTextResults = function (species_id, filters, results_container, results_button) {
  var url = IFBL.generateTextResultsUrl(species_id, filters, 'json');
  var $dltxt_link = $('<a href="' + IFBL.generateTextResultsUrl(species_id, filters, 'csv') + '">Download results as CSV</a>');
  var word;
  
  $.getJSON(url, function(data) {
    var nb_res = IFBL.countTxtResults(data);
    // Update the button label...
    if (nb_res > 0) {
      nb_res == 1 ? word = 'result' : word = 'results';
        
      results_button.button('option', 'label', 'View ' + nb_res + ' ' + word + ' as a table');
      results_button.button('option', 'disabled', false);
    }
    else {
      results_button.button('option', 'label', 'No results');
    }
    
    results_container.append($dltxt_link.button());
    results_container.append(IFBL.txtResultsToHtmlTable(data));      
  });
      
};


IFBL.generateBlockForChecklist = function(c) {
      var spi, i, $meta_p, $tab;
      
      var t = $('<div class="checklist"></div>')
        t.append($('<h2 class="checklist_title">'+ 'Checklist ' + c.id + '</h2>'));
	
        $meta_p = ($('<p class="cl_meta grid_4 alpha"></p>'));
        
        $tab = $('<table></table>')
            .append($('<tr><td>Model: </td><td>' + c.model + '</td></tr> '))
            .append($('<tr><td>Source: </td><td> ' + c.source + '</td></tr> '))
            .append($('<tr><td>Observed area: </td><td>' + c.concern_area + '</td></tr>'))
            .append($('<tr><td>Date: </td><td>' + 'from ' + c.begin_date + ' to ' + c.end_date + '</td></tr>'))
            .append($('<tr><td>Observers: </td><td> ' + c.observers + '</td></tr>'));
        
        $meta_p.append($tab);
        t.append($meta_p);

        sp = $('<p class="grid_8 omega"><b>Observed species: </b></p>');
        
        for ( i=0 ; i<c.species.length ; i++ ) {
          if (i>0) {
            sp.append(' • ');
          }
          sp.append('<a href="/ifbl?species=' + c.species[i][0] + '">' + c.species[i][1] + '</a>');
        }

        t.append(sp);
        
      return t;
    };

IFBL.generateVisiButton = function (for_layer) {
    var cb_id= ('cb_f_l_' + for_layer.id).split('.').join('');
    
    var $r = $('<span />');
    
    $r.append($('<label for="' + cb_id + '">Visible</label>'));
    
    var $cb = $('<input class="visi_checkbox" type="checkbox" id="' + cb_id +'" checked="checked" />');
    
    $cb.click(function() {
        if($(this).is(':checked')) {
          IFBL.current_page.adaptMapToCheckBox($('#generalize'), IFBL.current_page.map);
        } else {
          for_layer.setVisibility(false);
          for_layer.generalized_layer.setVisibility(false);
        }
          
      });
    
    $r.append($cb);
    
    return $r;
}

IFBL.generateTextResultsUrl = function(species_id, filters, format) {
  var url = '/ifbl/ajax/observations_per_species_and_time?species_id=' + species_id + '&format=' + format;      

      if ('date' in filters) {
        if (filters['date'] == 'before39') {
          url = url + "&end_date=1939-01-01";
        }
        else if (filters['date'] == '39-71') {
          url = url + "&start_date=1939-01-01&end_date=1971-12-31";
        }
        else if (filters['date'] == '72-04') {
          url = url + "&start_date=1972-01-01&end_date=2004-01-01";
        }
        else if (filters['date'] == 'after04') {
          url = url + "&start_date=2004-01-01";
        }
        else if (filters['date'] == 'free') {
          var s, e;

          if (filters['date_values']['start']) {
            s = filters['date_values']['start'];
          }
          else {
            s = "1000-01-01";
          }

          if (filters['date_values']['end']) {
            e = filters['date_values']['end'];
          }
          else {
            e = "70000-01-01";
          }
        url = url + "&start_date="+s+"&end_date="+e;
        }
      }

      if ('square' in filters) {
        url = url+ "&square_name=" +filters['square'];
      }
      
      return url;
},

IFBL.countTxtResults = function(results) {
  return results.length;
},

IFBL.txtResultsToHtmlTable = function (results) {
      var i,r,e,ce;
      
      var nb_results = IFBL.countTxtResults(results);
      
      if (nb_results == 0) {
	e = $('<p>No results.</p>');
      }
      else {
	e = $('<div class="rt_container"></div>');
	var $thetable = $('<table class="textresults"></table>');
	
	e.append($thetable);
	
	for (i=0 ; i<nb_results; i++) {
	  r = results[i].observation;
	  ce = $('<tr></tr>')
	  
	  ce.append($('<td>'+ r.ifbl_code + '</td>'));
	  ce.append($('<td>'+ r.begin_date + ' - ' + r.end_date + '</td>'));
	  ce.append($('<td class="observers">'+ r.observers + '</td>'));
	  
	  $thetable.append(ce);
	}
	
      }
           
      return e;
    },

IFBL.initMap = function(the_div) {
    var $phyto_legend, legend_entries, $phyto_legend_table, $phyto_legend_table_line;
    
    var options = {
      units: 'm',
      projection: "EPSG:900913",
      maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34),
      maxResolution: 156543.0339,
    };

    var map = new OpenLayers.Map(the_div, options);
    
    var gphy = new OpenLayers.Layer.Google(
        "Google Physical",
        {type: google.maps.MapTypeId.TERRAIN}
    );
    
    var ghyb = new OpenLayers.Layer.Google(
        "Google Hybrid",
        {type: google.maps.MapTypeId.HYBRID, numZoomLevels: 20}
    );
    var gsat = new OpenLayers.Layer.Google(
        "Google Satellite",
        {type: google.maps.MapTypeId.SATELLITE, numZoomLevels: 22}
    );
    
    var phyto = new OpenLayers.Layer.WMS(
                    "Ecoregions", IFBL.constants.wms_real_url,
                    {
                        srs: 'EPSG:900913',
                        layers: 'bbpf:ecoregions',
                        transparent: true
                    }, 
                    {
                        visibility: false
                    }
                    
                );
    $(phyto).data('add_to_my_switcher', true);
    
    $phyto_legend = $('<div title="Ecoregions legend"></div>');
    
    // Values are copy-pasted from SLD file
    legend_entries = [
        {title: 'Ardennes', color: '#3f38f0' },
        {title: 'Condroz', color: '#fb5966' },
        {title: 'Fagne - Famenne - Calestienne', color: '#54c2cd' },
        {title: 'Gaume - Lorraine', color: '#6b7b82' },
        {title: 'Thierache', color: '#e02463' },
        {title: 'Dune', color: '#1ddcf1' },
        {title: 'Campine', color: '#6aba3f' },
        {title: 'Loam', color: '#5f75f0' },
        {title: 'Gravel Meuse', color: '#e56631' },
        {title: 'Polder', color: '#418495' },
        {title: 'Sandyloam', color: '#9cb4d8' }
    ];
    
    $phyto_legend_table = $('<table></table>');
    
    $.each(legend_entries, function(i, entry) {
        $phyto_legend_table_line = $('<tr></tr>');
        $phyto_legend_table_line.append($('<td class="le_color" style="background-color:' + entry.color + ';">&nbsp</td>'));
        $phyto_legend_table_line.append($('<td class="le_title">' + entry.title + '</td>'));
        $phyto_legend_table.append($phyto_legend_table_line);
    }); 
    
    $phyto_legend.append($phyto_legend_table);
    
    $(phyto).data('legend_html', $phyto_legend);

    map.addLayers([gphy, ghyb, gsat, phyto]);

    map.setCenter(IFBL.constants.center_of_belgium.transform(
        new OpenLayers.Projection("EPSG:4326"),
        map.getProjectionObject()), 8);   

    return map;
 
}

