
import 'package:url_launcher/url_launcher_string.dart';

import '../global/global.dart';

class MapUtils{
  MapUtils._();

  static Future <void> launchMapFromSourceToDestination( purchaserLat,  purchaserLng,  destinationLat,  destinationLng )async
  {

    /*
      mapUrl = 'https://www.google.com/maps?saddr=$position,daddr=$destinationLat,$destinationLng&travelmode=driving&dir_action=navigate';
      if (await canLaunchUrl(Uri.parse(mapUrl))) {
        await launchUrl(Uri.parse(mapUrl));
      } else {
        throw 'Could not launch $mapUrl';
      }

*/
    String mapOptions =
    [
      'saddr=$purchaserLat,$purchaserLng',
      'daddr=$destinationLat,$destinationLng',
      'dirt_action=navigate'
    ].join('&');

    final mapUrl = 'https:/www.google.com/maps?$mapOptions';

    if (await canLaunchUrlString(mapUrl)){
      await launchUrlString(mapUrl);
    }else{

      throw 'Could not launch $mapUrl';
    }
  }
}