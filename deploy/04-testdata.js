const format  = require('date-fns/format');
const { newCollection } = require('../utils/createCollection');

const data = [
  // Now
  {
    name: '2023 Club Mavericks Season',
    eventLocation: 'American Airlines Center',
    description:
      "Don't miss any of the action next season! Elevate your MFFL status by becoming a Club Maverick member. Enjoy all the benefits when you secure your 2021-2022 season tickets!",
    imageUrl: 'https://static.duckee.xyz/pocky/banner1.png',
    startDate: new Date('2023-06-01'),
    endDate: new Date('2023-06-15T19:00:00'),
    featured: true,
  },
  {
    name: '2023 NBA Finals : Miami Heat at Denver',
    eventLocation: 'Ball Arena',
    description:
      'Get ready for the Finals with interactive stats visuals breaking down the Nuggets vs. Heat matchup. Chicken Nuggets are cool.',
    imageUrl: 'https://static.duckee.xyz/pocky/banner2.png',
    startDate: new Date('2023-06-01'),
    endDate: new Date('2023-06-15T19:00:00'),
  },
  {
    name: '2023 NFL London Game at Wembley Stadium',
    eventLocation: 'Wembley Stadium',
    description:
      '2023 NFL London Games are back to the stadium. Register your ticket right now and keep special memories of your best moments!',
    imageUrl: 'https://static.duckee.xyz/pocky/banner3.png',
    startDate: new Date('2023-06-01'),
    endDate: new Date('2023-06-15T19:00:00'),
  },
  // Upcoming
  {
    name: '2023 SUPER BOWL',
    eventLocation: 'MetLife Stadium',
    description:
      '2023 SUPER BOWL is now on live! The Super Bowl is the biggest and most important American football game of the year. It is the National Football League (NFL) yearly championship game.',
    imageUrl: 'https://static.duckee.xyz/pocky/banner4.png',
    startDate: new Date('2023-06-14'),
    endDate: new Date('2023-06-18'),
  },
  {
    name: 'MLB ALL STAR GAME',
    eventLocation: 'T-Mobile Park',
    description:
      'Capital One PLAY BALL PARK has something for every fan. There’s the MLB Gaming Zone, the World’s Largest Baseball, meet and greets with the Legends of the game and so much more!',
    imageUrl: 'https://static.duckee.xyz/pocky/banner5.png',
    startDate: new Date('2023-06-14'),
    endDate: new Date('2023-06-18'),
  },
  {
    name: 'UFC Fight Night London',
    eventLocation: 'The O2 Arena',
    description:
      "UFC returned to the UK for the first time in three years in March for UFC FIGHT NIGHT®: VOLKOV vs. ASPINALL at The O2, welcoming a sell-out crowd of over 17,000. Following the success of UFC's return to the UK, the promotion will host its second event at London's The O2 this year.",
    imageUrl: 'https://static.duckee.xyz/pocky/banner6.png',
    startDate: new Date('2023-06-14'),
    endDate: new Date('2023-06-18'),
  },
  // Past
  {
    name: '2023 NBA Playoffs : Miami vs Boston',
    eventLocation: 'FTX Arena',
    description:
      'Get ready for the Finals with interactive stats visuals breaking down the Nuggets vs. Heat matchup. Chicken Nuggets are cool.',
    imageUrl: 'https://static.duckee.xyz/pocky/banner7.jpeg',
    startDate: new Date('2023-05-20'),
    endDate: new Date('2023-05-27T19:00:00'),
  },
  {
    name: '2023 NBA League : Cleverand vs Charlotte',
    eventLocation: 'Spectrum Center',
    description:
      "The Charlotte Hornets are an American professional basketball team based in Charlotte, North Carolina. The Hornets compete in the National Basketball Association, as a member of the league's Eastern Conference Southeast Division.",
    imageUrl: 'https://static.duckee.xyz/pocky/banner8.jpeg',
    startDate: new Date('2023-03-07'),
    endDate: new Date('2023-03-14T19:00:00'),
  },
];

module.exports = async ({ getNamedAccounts, ethers }) => {
  const { deployer } = await getNamedAccounts();
  const pockyCollections = await ethers.getContract('PockyCollections');

  // default values
  const price = 0.01;
  const owner = deployer;
  const maxSupply = 100;

  console.log('----------------------------------------------------');
  console.log('Registering test data to PockyCollections...');
  let collectionId = 0;
  for (const { name, eventLocation, description, imageUrl, startDate, endDate, featured } of data) {
    const collection = await newCollection(
      name,
      price,
      owner,
      maxSupply,
      startDate,
      endDate,
      eventLocation,
      description,
      imageUrl,
      !!featured,
    );
    // console.log(collection);

    await pockyCollections.register(collection);
    console.log(
      `- collection #${collectionId++} created: ${name} (${format(startDate, 'yyyyMMdd')} ~ ${format(
        endDate,
        'yyyyMMdd',
      )})`,
    );
  }
};
