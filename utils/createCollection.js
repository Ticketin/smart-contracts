const ethers = require('ethers');
const format = require('date-fns/format');

/**
 * Creates a new `PockyCollections.Collection` object.
 *
 * @param {string} name           the title of the event. (e.g. "2023 NBA Finals : Miami Heat at Denver")
 * @param {number} price          the price of each ticket in ETH/MATIC. (e.g. 0.1)
 * @param {string} owner          the address of the owner of the collection. (e.g. "0x58AeABfE2D9780c1bFcB713Bf5598261b15dB6e5")
 * @param {number} maxSupply      the cap of ticket supply. (e.g. 500)
 * @param {Date} startDate        the start date of the event. (e.g. new Date("2023-05-20"))
 * @param {Date} endDate          the end date of the event. (e.g. new Date("2023-05-27"))
 * @param {string} eventLocation  the location of the event. (e.g. "TD GARDEN, 100 Legends Way, Boston, MA")
 * @param {string} description    the description of the event.
 * @param {string} imageUrl       the IPFS URL of the banner image of the event.
 * @param {boolean} featured      whether the event is featured or not.
 */
async function newCollection(
  name,
  price,
  owner,
  maxSupply,
  startDate,
  endDate,
  eventLocation,
  description,
  imageUrl,
  featured,
) {
  const matchDate = format(endDate, 'yyyyMMdd');
  const ticketSvgMetadata = await fetchTicketSvgMetadata(endDate, eventLocation);

  return {
    name,
    priceInETH: ethers.utils.parseEther(String(price)),
    owner,
    maxSupply,
    startDate: +startDate,
    endDate: +endDate,
    matchDate,
    ticketSvgMetadata,
    eventLocation,
    description,
    imageUrl,
    featured,
    updated: false,
    eventResult: {
      homeScore: '0',
      homeFGM: '',
      homeFGP: '',
      homeTPM: '',
      homeTPP: '',
      homeFTM: '',
      homeFTP: '',
      awayScore: '0',
      awayFGM: '',
      awayFGP: '',
      awayTPM: '',
      awayTPP: '',
      awayFTM: '',
      awayFTP: '',
    },
  };
}


/**
 * Fetches `ticketSvgMetadata` from the Pocky API.
 * @param {Date} matchDate the match date - usually the end date.
 * @param {string} location the location of the match.
 */
async function fetchTicketSvgMetadata(matchDate, location) {
  const matchDateYmd = format(matchDate, 'yyyyMMdd');
  const matchDateFull = format(matchDate, 'EEEE, MMM d p').toUpperCase();

  const response = await fetch(`https://pocky.deno.dev/api/sport/nba/${matchDateYmd}`);
  if (!response.ok) {
    const {
      error: { code, message },
    } = await response.json();
    throw new Error(`${code}: ${message} for ${matchDate} (${response.status}: ${response.statusText})`);
  }
  const { home, away } = await response.json();
  return {
    homeTeamName: home.metadata.name,
    homeTeamSymbol: home.metadata.symbol,
    homeTeamLogo: home.metadata.logo,
    homeTeamColor: home.metadata.color,
    awayTeamName: away.metadata.name,
    awayTeamSymbol: away.metadata.symbol,
    awayTeamLogo: away.metadata.logo,
    awayTeamColor: away.metadata.color,
    dateLine1: matchDateFull.split(' ')[0], // e.g. "WEDNESDAY,"
    dateLine2: matchDateFull.split(', ')[1], // e.g. "MAY 27 7:00PM"
    locationLine1: location.toUpperCase().split(', ')[0], // e.g. "TD GARDEN,"
    locationLine2: location.toUpperCase().split(', ').slice(1).join(', '), // e.g. "100 LEGENDS WAY, BOSTON, MA"
    qrCodeUrl: `https://pocky.deno.dev/api/qrcode/${Math.floor(Math.random() * 1000)}`,
  };
}

module.exports = {
  newCollection,
  fetchTicketSvgMetadata,
};
