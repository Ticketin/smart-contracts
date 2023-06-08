const { expect } = require('chai');
const { deployments, ethers } = require('hardhat');
const { writeFile } = require('fs/promises');

const UPCOMING_EVENT_DATA = {
  name: '2023 NBA Finals : Miami Heat at Denver',
  priceInETH: ethers.utils.parseEther('0.1'),
  owner: '0x58AeABfE2D9780c1bFcB713Bf5598261b15dB6e5',
  maxSupply: 100,
  startDate: Date.parse('2023-05-20'),
  endDate: Date.parse('2023-05-27'),
  matchDate: '20230527',
  ticketSvgMetadata: {
    homeTeamName: 'Boston Celtics',
    homeTeamSymbol: 'BOS',
    homeTeamLogo: 'https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/bos.png',
    homeTeamColor: '#006532',
    awayTeamName: 'Miami Heat',
    awayTeamSymbol: 'MIA',
    awayTeamLogo: 'https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/mia.png',
    awayTeamColor: '#98002e',
    dateLine1: 'WEDNESDAY,',
    dateLine2: 'MAY 27 PM 7:00',
    locationLine1: 'TD GARDEN,',
    locationLine2: '100 Legends Way, Boston, MA',
    qrCodeUrl: 'https://pocky.deno.dev/api/qrcode/0',
  },
  eventLocation: 'TD GARDEN, 100 Legends Way, Boston, MA',
  description:
    '2023 SUPER BOWL is now on live! The Super Bowl is the biggest and most important American football game of the year. It is the National Football League (NFL) yearly championship game.',
  imageUrl: 'https://titleleaf.nyc3.cdn.digitaloceanspaces.com/cherrylake/product/cover/xl_9781668919569_fc.jpg',
  featured: false,
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

const FINISHED_EVENT_DATA = {
  ...UPCOMING_EVENT_DATA,
  eventResult: {
    homeScore: '112',
    homeFGM: '42',
    homeFGP: '52.7%',
    homeTPM: '23',
    homeTPP: '48.2%',
    homeFTM: '11',
    homeFTP: '58.1%',
    awayScore: '108',
    awayFGM: '42',
    awayFGP: '52.3%',
    awayTPM: '13',
    awayTPP: '38.4%',
    awayFTM: '15',
    awayFTP: '64.5%',
  },
  updated: true,
};

describe('TickeySVGRenderer', () => {
  let collections;

  beforeEach(async () => {
    await deployments.fixture(['PockyCollections']);
    collections = await ethers.getContract('PockyCollections');
  });

  describe('svgOf()', () => {
    it('should render the right svg', async () => {
      await collections.register(UPCOMING_EVENT_DATA);
      await collections.register(FINISHED_EVENT_DATA);

      const upcomingSvg = await collections.svgOf(0);
      expect(upcomingSvg).to.match(/Upcoming/);

      const finishedSvg = await collections.svgOf(1);
      expect(finishedSvg).to.match(/Result/);
      expect(finishedSvg).to.match(/52\.7\%/);

      await writeFile('test-upcoming.svg', upcomingSvg);
      await writeFile('test-finished.svg', finishedSvg);
      console.log('successfully write test-upcoming.svg');
      console.log('successfully write test-finished.svg');
    });
  });
});
