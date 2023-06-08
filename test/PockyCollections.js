const { expect } = require('chai');

describe('PockyCollections', () => {
  let collections;

  beforeEach(async () => {
    await deployments.fixture(['PockyCollections', 'Ticket', 'Testdata']);
    collections = await ethers.getContract('PockyCollections');
  });

  it('should return metadata of the collection', async () => {
    const tokenUri = await collections.constructTokenURIOf(0);
    const { name, description, animation_url } = JSON.parse(
      Buffer.from(tokenUri.replace('data:application/json;base64,', ''), 'base64').toString('utf-8'),
    );

    expect(name).to.equal('2023 Club Mavericks Season - Pocky dNFT Ticket');
    expect(description).to.equal(
      "Don't miss any of the action next season! Elevate your MFFL status by becoming a Club Maverick member. Enjoy all the benefits when you secure your 2021-2022 season tickets!",
    );
    expect(animation_url).to.be.a('string');
    expect(animation_url.startsWith('https://pocky.deno.dev/render?svg=PHN2ZyB3aWR0aD0iODQ4IiBoZWlnaHQ9Ij')).to.be.true;
  });
});
