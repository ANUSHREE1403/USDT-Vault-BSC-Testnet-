# USDT Vault (BSC Testnet)

This is a **learning project** I built to understand:

- How ERC20 / BEP20 tokens actually work with `approve` + `transferFrom`
- How to deploy contracts on **BNB Smart Chain Testnet**
- How to connect a **React** frontend to real contracts using **ethers + MetaMask**

No hype, no trading bot.  
Just me wiring things together so I properly get the flow end‑to‑end.

---

## What this project does-

On BSC **testnet**:

- I deployed a simple USDT‑like token (`TestUSDT`).
- I deployed a small helper contract (`CleanFlashUSDTBsc`) that:
  - Can hold USDT and BNB.
  - Lets the owner deposit USDT into the contract.
  - Lets the owner withdraw USDT or BNB back out.
- Then I built a React UI where I can:
  - Connect MetaMask (BSC testnet).
  - Approve USDT to the helper contract.
  - Deposit USDT from my wallet into the contract.
  - Withdraw USDT from the contract back to my wallet.
  - See the contract balances update live.

That’s it. No nonsense!

---

## Contracts (BSC Testnet)

### `TestUSDT.sol`

Super simple token, only for testing:

- `name = "Test USDT"`
- `symbol = "tUSDT"`
- `decimals = 18`
- On deploy it mints `1,000,000 tUSDT` to my own wallet.

Key functions I care about:

- `balanceOf(address)`
- `approve(address spender, uint256 amount)`
- `allowance(address owner, address spender)`
- `transferFrom(address from, address to, uint256 amount)`

### `CleanFlashUSDTBsc.sol`

Helper contract that talks to the USDT token:

- Stores:
  - `IERC20 public usdt;` – the token address (injected in constructor).
  - `address public owner;` – deployer address.
- `onlyOwner` modifier so **only I** can move funds.

Main functions:

- `depositUSDT(uint256 amount)`  
  - `onlyOwner`  
  - Calls `usdt.transferFrom(owner, address(this), amount)`  
  - So it depends on the ERC20 `allowance` being set first.
- `withdrawUSDT(uint256 amount, address to)`  
  - `onlyOwner`  
  - Sends USDT from this contract to `to`.
- `usdtBalance()`  
  - Returns how much USDT the contract is holding.
- `withdrawBNB(...)` + `bnbBalance()`  
  - Same idea for the native BNB.

If you read the Solidity, everything is short and boring on purpose. I wanted it to be 100% clear what happens with every token.

---

## Deployed testnet addresses

These are **BNB Smart Chain Testnet** only:

- `TestUSDT` (tUSDT) token:  
  `0xc8e6590fa17197ca6403ad361050bc542cb9a738`

- `CleanFlashUSDTBsc` helper:  
  `0x98061f2f28439cc95f57b68d7c05da9456949ff2`

You can plug them into [BscScan Testnet](https://testnet.bscscan.com/) and inspect all the tx history.

---

## Frontend (`usdt/ui`)

The frontend is a small React app built with:

- React + TypeScript
- Vite
- Tailwind
- ethers v6

The base UI/UX layout and components are generated from a **Lovable** starter (shadcn‑style wallet interface).  
On top of that, I wired all the Web3 logic, contract config, and the Flash USDT panel myself with the help of AI obviously.

The interesting part is in:

- `src/config/web3.ts` – chain id, contract addresses, and minimal ABIs.
- `src/lib/flashUsdt.ts` – sets up `BrowserProvider` from `window.ethereum`, enforces BSC testnet, and returns ethers `Contract` instances.
- `src/components/FlashUsdtPanel.tsx` – the actual UI panel.

### Flash USDT panel

What the panel does:

- **Load balances**  
  Calls `bnbBalance()` and `usdtBalance()` on `CleanFlashUSDTBsc`.
- **Approve USDT**  
  Calls `TestUSDT.approve(FLASH_ADDR, maxAmount)` so the helper contract is allowed to pull USDT from my wallet.
- **Deposit**  
  Calls `CleanFlashUSDTBsc.depositUSDT(amount)` with the amount from the input.
- **Withdraw to me**  
  Calls `CleanFlashUSDTBsc.withdrawUSDT(amount, myAddress)`.

Errors are made readable:

- If I reject a transaction in MetaMask, UI just says:  
  **“Transaction was rejected in MetaMask.”**

---

## How to run it locally

1. Clone this repo.
2. Install and run the UI:

```bash
cd usdt/ui
npm install --legacy-peer-deps
npm run dev
```

3. In MetaMask:
   - Switch to **BNB Smart Chain Testnet**.
4. Open the Vite URL (e.g. `http://localhost:5173`), go to the **Trade** page, then:

   - Click **Load balances** to see what the contract is holding.
   - Click **Approve USDT** once (confirm in MetaMask).
   - Type an amount (e.g. `1`) and press **Deposit**.
   - Use **Withdraw to me** to send it back.

---

## Why I built this

I got tired of copy‑paste “flash loan bot” code that makes zero sense, so I wanted:

- A very small, honest example I actually understand.
- Full flow from **Solidity → deployment → ethers.js → UI**.
- Something I can break, tweak, and extend as I learn more.

My curiosity and hunger for learning are kind of dragging me into different “planets” of this dev galaxy.  
With this project, I’m officially stepping onto the **Web3 planet** – not as an expert, just as someone who actually wants to understand what’s going on under the hood.

If you’re also exploring and experimenting, feel free to connect – always happy to meet other hungry learners.

Made with the love for coding and exploring.

