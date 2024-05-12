const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const app = express();
const { Web3 } = require('web3');

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const ALCHEMY_RPC_URL = process.env.ALCHEMY_RPC_URL;
const RPC_HOST = `${ALCHEMY_RPC_URL}/${ALCHEMY_API_KEY}`;

const provider = new Web3.providers.HttpProvider(RPC_HOST);
const web3 = new Web3(provider);

app.use(express.json());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(helmet());

/**
 * @param {*} req - The request http object
 * @param {*} res - The response http object
 * @returns - If success, the balance, otherwise, an error
 */
app.get('/api/v1/balance/:contractAddress', async (req, res, next) => {
    const address = req.params.contractAddress;

    if (!address) {
        const required = address == null ? "address" : "";

        return res.status(400).send({
            msg: `The ${required} is required!`
        });
    }

    try {
        const balanceOf = await getBalance(address);

        return res.status(200).send({
            balance: (balanceOf == "0." ? "0" : balanceOf)
        });
    } catch (error) {
        return res.status(500).send({
            msg: `An error occurr when try to get the balance of ${address}!\n Error: ${error}`
        });
    };
});

async function getBalance(contractAddress) {
    const balance = await web3.eth.getBalance(contractAddress);
    return web3.utils.fromWei(balance, 'ether');
}

app.listen(process.env.PORT || 3000, () => {
    console.log(`App Express is running!`);
    console.log('Server listening on port 3000');
});
