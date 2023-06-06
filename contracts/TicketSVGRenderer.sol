// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {PockyCollections} from './PockyCollections.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';

library TicketSVGRenderer {
  string public constant NBA_HEADER =
    '<svg width="848" height="848" viewBox="0 0 848 848" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs><style>@font-face { font-family: "NBA"; src: url("https://static.duckee.xyz/NBA-Pacers.woff2"); }.ta { font: bold 80px Arial; fill: white; letter-spacing: -0.03em; }.ta2 { font-size: 18px; fill: black; } .ta3 { font-size: 24px; fill: black; } .tn { font: 47px NBA, sans-serif; letter-spacing: -0.03em; fill: white; }.tn2 { fill: #828282; font-size: 24px; } .tn3 { fill: #646464; font-size: 24px; }</style><pattern id="nbalogo" patternContentUnits="objectBoundingBox" width="1" height="1"><use xlink:href="#inba" transform="scale(0.0026178 0.00152439)" /></pattern><clipPath id="cb"><rect width="848" height="848" fill="white" /></clipPath><image id="inba" width="382" height="656" xlink:href="https://static.duckee.xyz/nba.png" /></defs><g clip-path="url(#cb)"><path d="M24 0H535C535 17.6731 549.327 32 567 32V816C549.327 816 535 830.327 535 848H24V0Z" fill="#F3F3F3" /><path d="M16 0.5L239.5 0.5L239.5 847.5H16C7.43959 847.5 0.5 840.56 0.5 832L0.5 16C0.5 7.43957 7.43959 0.5 16 0.5Z" fill="black" stroke="#F5F5F5" /><rect x="24" y="494" width="191" height="328" fill="url(#nbalogo)" /><path d="M567 35L567 813" stroke="#CECECE" stroke-width="3" stroke-linecap="round" stroke-dasharray="40 40" /><path d="M599 -0.000976562C599 17.6721 584.673 31.999 567 31.999V815.999C584.673 815.999 599 830.326 599 847.999H832C840.837 847.999 848 840.836 848 831.999V15.999C848 7.16247 840.837 -0.000976562 832 -0.000976562H599Z" fill="#F5F5F5" /><line x1="567" y1="283.999" x2="848" y2="283.999" stroke="white" stroke-width="2" /><circle cx="708" cy="284.999" r="56" transform="rotate(-90 708 284.999)" stroke="white" stroke-width="2" /><circle cx="704" cy="455.999" r="50" transform="rotate(-90 704 455.999)" stroke="white" stroke-width="2" /><path d="M693.239 602.009L693.172 602H693.104H599L599 494C599 433.801 647.801 385 708 385C768.199 385 817 433.801 817 494V602H722.896H722.828L722.761 602.009C717.935 602.662 713.007 603 708 603C702.993 603 698.065 602.662 693.239 602.009Z" stroke="white" stroke-width="2" /><path d="M722.761 -32.009L722.828 -32L722.896 -32L817 -32L817 76C817 136.199 768.199 185 708 185C647.801 185 599 136.199 599 76L599 -32L693.104 -32L693.172 -32L693.239 -32.009C698.065 -32.6625 702.993 -33 708 -33C713.007 -33 717.935 -32.6625 722.761 -32.009Z" stroke="white" stroke-width="2" /><rect x="654" y="601.999" width="145" height="100" transform="rotate(-90 654 601.999)" stroke="white" stroke-width="2" /><rect x="654" y="118.999" width="118" height="100" transform="rotate(-90 654 118.999)" stroke="white" stroke-width="2" /><circle cx="704" cy="113.999" r="50" transform="rotate(90 704 113.999)" stroke="white" stroke-width="2" /><path d="M567 35L567 813" stroke="#CECECE" stroke-width="3" stroke-linecap="round" stroke-dasharray="40 40" /><rect x="771" width="46" height="240" fill="#E73325" /><rect x="714" width="46" height="198" fill="#E73325"/><text transform="translate(718 189) rotate(-90)" class="tn"><tspan x="0.430511" y="37.694">2023 NBA</tspan></text><text transform="translate(775 231) rotate(-90)" class="tn"><tspan x="0.565628" y="37.694">GAME TICKET</tspan></text>';
  string public constant NBA_FOOTER = '</g></svg>';

  function renderSVG(PockyCollections.Collection memory collection) public pure returns (string memory svg) {
    if (collection.updated) {
      return renderResultNbaTicket(collection);
    }
    return renderUpcomingNbaTicket(collection);
  }

  function renderUpcomingNbaTicket(
    PockyCollections.Collection memory collection
  ) internal pure returns (string memory svg) {
    return
      string(
        abi.encodePacked(
          NBA_HEADER,
          renderMatchScoreline(collection, 'Upcoming'),
          renderMatchInfo(collection),
          renderBackground(collection, false),
          NBA_FOOTER
        )
      );
  }

  function renderResultNbaTicket(
    PockyCollections.Collection memory collection
  ) internal pure returns (string memory svg) {
    return
      string(
        abi.encodePacked(
          NBA_HEADER,
          renderMatchScoreline(collection, 'Result'),
          renderMatchInfo(collection),
          renderBackground(collection, true),
          renderResultForm(56, collection.ticketSvgMetadata.homeTeamLogo, collection.ticketSvgMetadata.homeTeamName),
          renderResultForm(477, collection.ticketSvgMetadata.awayTeamLogo, collection.ticketSvgMetadata.awayTeamName),
          renderHomeStats(collection),
          renderAwayStats(collection),
          NBA_FOOTER
        )
      );
  }

  function renderMatchScoreline(
    PockyCollections.Collection memory collection,
    string memory matchStatus
  ) internal pure returns (string memory svg) {
    return
      string(
        abi.encodePacked(
          '<text transform="translate(24 60)" fill="#828282" font-family="NBA" font-size="36">',
          matchStatus,
          '</text><text transform="translate(20 80)" class="ta"><tspan x="0" y="73.7344">',
          collection.ticketSvgMetadata.homeTeamSymbol,
          '</tspan></text><text transform="translate(20 172)" class="ta"><tspan x="0" y="73.7344">',
          collection.eventResult.homeScore,
          '</tspan></text><text transform="translate(20 284)" class="ta"><tspan x="0" y="73.7344">',
          collection.ticketSvgMetadata.awayTeamSymbol,
          '</tspan></text><text transform="translate(20 376)" class="ta"><tspan x="0" y="73.7344">',
          collection.eventResult.awayScore,
          '</tspan></text>'
        )
      );
  }

  function renderMatchInfo(PockyCollections.Collection memory collection) internal pure returns (string memory svg) {
    return
      string(
        abi.encodePacked(
          '<text transform="translate(607 556) rotate(-90)" class="tn tn2"><tspan x="0" y="19.248">DATE</tspan></text><text transform="translate(775.5 556) rotate(-90)" class="ta ta2"><tspan x="0" y="16.7402">',
          collection.ticketSvgMetadata.locationLine1,
          '</tspan><tspan x="0" y="40">',
          collection.ticketSvgMetadata.locationLine2,
          '</tspan></text><text transform="translate(743 556) rotate(-90)" class="tn tn2"><tspan x="0" y="19.248">LOCATION</tspan></text><text transform="translate(639 556) rotate(-90)" class="ta ta2"><tspan x="0" y="16.7402">',
          collection.ticketSvgMetadata.dateLine1,
          '</tspan><tspan x="0" y="40">',
          collection.ticketSvgMetadata.dateLine2,
          '</tspan></text>',
          renderSquareImage('602', '592', '215', collection.ticketSvgMetadata.qrCodeUrl)
        )
      );
  }

  function renderBackground(
    PockyCollections.Collection memory collection,
    bool transparent
  ) internal pure returns (string memory svg) {
    string memory images = string(
      abi.encodePacked(
        renderSquareImage('256', '66', '295', collection.ticketSvgMetadata.homeTeamLogo),
        renderSquareImage('256', '487', '295', collection.ticketSvgMetadata.awayTeamLogo)
      )
    );
    if (transparent) {
      return string(abi.encodePacked('<g opacity="0.07">', images, '</g>'));
    }
    return images;
  }

  function renderResultForm(
    uint256 baseY,
    string memory logo,
    string memory name
  ) internal pure returns (string memory svg) {
    string memory nameY = Strings.toString(baseY + 9);
    string memory headingY = Strings.toString(baseY + 72);
    return
      string(
        abi.encodePacked(
          renderSquareImage('264', Strings.toString(baseY), '48', logo),
          '<text transform="translate(324 ',
          nameY,
          ')" class="ta ta3"><tspan x="0" y="22.3203">',
          name,
          '</tspan></text><text transform="translate(264 ',
          headingY,
          ')" class="tn tn3"><tspan x="0" y="19.248">FIELD GOALS MADE</tspan><tspan x="0" y="61.248">FIELD GOALS PCT</tspan><tspan x="0" y="103.248">3 POINTS MADE</tspan><tspan x="0" y="145.248">3 POINTS PCT</tspan><tspan x="0" y="187.248">FREE THROWS MADE</tspan><tspan x="0" y="229.248">FREE THROWS PCT</tspan></text>'
        )
      );
  }

  function renderHomeStats(PockyCollections.Collection memory collection) internal pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          '<text transform="translate(453 126)" class="ta ta3"><tspan x="0" y="20">',
          collection.eventResult.homeFGM,
          '</tspan><tspan x="0" y="62">',
          collection.eventResult.homeFGP,
          '</tspan><tspan x="0" y="104">',
          collection.eventResult.homeTPM,
          '</tspan><tspan x="0" y="146">',
          collection.eventResult.homeTPP,
          '</tspan><tspan x="0" y="188">',
          collection.eventResult.homeFTM,
          '</tspan><tspan x="0" y="230">',
          collection.eventResult.homeFTP,
          '</tspan></text>'
        )
      );
  }

    function renderAwayStats(PockyCollections.Collection memory collection) internal pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          '<text transform="translate(453 549)" class="ta ta3"><tspan x="0" y="20">',
          collection.eventResult.awayFGM,
          '</tspan><tspan x="0" y="62">',
          collection.eventResult.awayFGP,
          '</tspan><tspan x="0" y="104">',
          collection.eventResult.awayTPM,
          '</tspan><tspan x="0" y="146">',
          collection.eventResult.awayTPP,
          '</tspan><tspan x="0" y="188">',
          collection.eventResult.awayFTM,
          '</tspan><tspan x="0" y="230">',
          collection.eventResult.awayFTP,
          '</tspan></text>'
        )
      );
  }

  function renderSquareImage(
    string memory x,
    string memory y,
    string memory size,
    string memory href
  ) internal pure returns (string memory svg) {
    return
      string(
        abi.encodePacked(
          '<image x="',
          x,
          '" y="',
          y,
          '" width="',
          size,
          '" height="',
          size,
          '" preserveAspectRatio="xMidYMid slice" href="',
          href,
          '"/>'
        )
      );
  }
}
