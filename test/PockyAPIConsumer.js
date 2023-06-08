const { expect } = require('chai');

const TEST_COLLECTION_ID = 6;
const TEST_COLLECTION_MATCH_DATE = '20230527';

describe('PockyAPIConsumer', () => {
  let collections;
  let apiConsumer;

  beforeEach(async () => {
    await deployments.fixture(['PockyCollections', 'Ticket', 'PockyAPIConsumer', 'Testdata']);
    collections = await ethers.getContract('PockyCollections');
    apiConsumer = await ethers.getContract('PockyAPIConsumer');
  });

  it('should update the event result', async () => {
    // before update, the result should be empty
    const before = await collections.get(TEST_COLLECTION_ID);
    expect(before.updated).to.be.false;
    expect(before.eventResult.homeScore).to.equal('0');
    expect(before.eventResult.homeFGM).to.equal('');

    // simulate chainlink oracle. fetch the data...
    const response = await fetch(`https://pocky.deno.dev/api/sport/nba/${TEST_COLLECTION_MATCH_DATE}`);
    const { oracleResultAbiData, home, away  } = await response.json();
    expect(oracleResultAbiData).to.be.a('string');

    // ...and post the result to the contract

    const tx = await apiConsumer.updateEventResult(TEST_COLLECTION_ID, oracleResultAbiData);
    await tx.wait();

    // after update, the result should be updated
    const after = await collections.get(TEST_COLLECTION_ID);
    expect(after.updated).to.be.true;
    expect(after.eventResult.homeScore).to.equal(String(home.score));
    expect(after.eventResult.homeFGM).to.equal(home.stats.fieldGoalsMade);
  });
});
