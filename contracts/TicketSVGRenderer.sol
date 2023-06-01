// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library TicketSVGRenderer {
  struct SVGInput {
    string title;
    string description1;
    string description2;
    string foregroundColor;
    string backgroundImage;
    string contentImage;
    bool hasResult;
    string resultText;
  }

  function renderSVG(SVGInput memory input) internal pure returns (string memory svg) {
    return
      string(
        abi.encodePacked(
          '<svg width="384" height="653" viewBox="0 0 384 653" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
          '<rect width="384" height="653" rx="32" fill="url(#bg)" />',
          '<text opacity="0.5" fill="white" xml:space="preserve" style="white-space: pre" font-family="Arial" font-size="16" letter-spacing="0em"><tspan x="32" y="483.547">',
          input.description1,
          '&#10;</tspan><tspan x="32" y="507.547">',
          input.description2,
          '</tspan></text>',
          '<text fill="white" xml:space="preserve" style="white-space: pre" font-family="Arial" font-size="42" letter-spacing="-0.02em">',
          '<tspan x="32" y="552.561">',
          input.title,
          '</tspan>',
          '<tspan x="32" y="600.561">',
          input.resultText,
          '</tspan></text>',
          '<rect x="27.5" y="23.5" width="328" height="428" rx="31.5" fill="url(#fg)" />',
          '<defs>',
          '<pattern id="bg" patternContentUnits="objectBoundingBox" width="1" height="1"><use xlink:href="#bg_image" transform="matrix(0.00876557 0 0 0.00515464 -0.323964 0)" /></pattern>',
          '<pattern id="fg" patternContentUnits="objectBoundingBox" width="1" height="1><use xlink:href="#fg_image" transform="matrix(0.000988142 0 0 0.000757806 0 -0.0122769)" /></pattern>',
          '<image id="bg_image" width="188" height="194" xlink:href="',
          input.backgroundImage,
          '" />',
          '<image id="fg_image" width="1012" height="1352" xlink:href="',
          'https://gcdnb.pbrd.co/images/iP5Is5XH7a48.png?o=1',
          '" />',
          '</defs>',
          '</svg>'
        )
      );
  }
}
