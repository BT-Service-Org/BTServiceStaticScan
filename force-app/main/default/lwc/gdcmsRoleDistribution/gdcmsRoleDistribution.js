import { LightningElement, api, wire} from 'lwc';
import ICONS from "@salesforce/resourceUrl/GDCIcons";
import getTeamMemberCount from '@salesforce/apex/GDC_MS_HeadCount.getTeamMemberCount';

export default class GdcmsMainFlipperContent extends LightningElement {

  @api GDCRolesContentId;
  @api PracticeAreaContentId;
  @api GDCOverviewContentId;
  location = ICONS + '/GDCIcons/icon_location.png';
  project = ICONS + '/GDCIcons/icon_projects.png';
  region = ICONS + '/GDCIcons/icon_regions.png';
  team = ICONS + '/GDCIcons/icon_team.png';

  @wire(getTeamMemberCount) totalHeadCount;
}