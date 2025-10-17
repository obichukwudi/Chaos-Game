🌀 Chaos-Game Clarity Contract
Overview

Chaos-Game is a Clarity smart contract that generates on-chain fractal art—specifically Sierpinski triangle patterns—using block hash entropy as a source of randomness.
Each fractal generated is unique, deterministic from on-chain data, and permanently stored, allowing anyone to reproduce or verify it on the blockchain.

✨ Features

🎨 On-chain fractal generation: Produces Sierpinski triangle points directly on-chain using a pseudo-randomized process.

🔐 Entropy from block hashes: Uses the previous block’s hash to inject unpredictable randomness.

🧮 Deterministic chaos: Although random in appearance, results are reproducible given the same inputs.

📦 Immutable storage: Saves both the fractal points and metadata (iterations, entropy, block height).

🧍‍♂️ Owner tracking: Automatically sets the contract deployer (tx-sender) as the owner.

🧩 Contract Architecture
Constants
Constant	Description
MAX-ITERATIONS	Maximum allowed fractal iterations (u1000)
SCALE-FACTOR	Base scaling unit for triangle coordinates
CONTRACT-OWNER	The deploying account (authorized owner)
ERR-*	Standardized error codes for validation and access control
Data Variables
Variable	Type	Description
current-seed	uint	Keeps track of entropy updates
total-fractals-generated	uint	Counts total number of generated fractals
Data Maps
Map	Key	Value	Description
fractal-points	uint	(list 1000 {x: uint, y: uint})	Stores generated points for each fractal
fractal-metadata	uint	{iterations, block-height, entropy}	Metadata for each fractal generation
⚙️ Public Functions
(generate-fractal (iterations uint)) → (response uint uint)

Generates a new fractal with the given number of iterations (up to MAX-ITERATIONS).

Validates iteration count.

Retrieves previous block hash for entropy.

Generates Sierpinski points using generate-sierpinski-points.

Stores results in fractal-points and fractal-metadata.

Returns the new fractal ID.

Errors:

ERR-INVALID-ITERATIONS – if iteration count exceeds limit

ERR-GENERATION-FAILED – if block info cannot be retrieved

👁️ Read-Only Functions
Function	Returns	Description
(get-fractal-points fractal-id)	Optional list of {x, y}	Retrieves fractal coordinates
(get-fractal-metadata fractal-id)	Optional metadata record	Returns stored metadata for a fractal
(get-total-fractals)	uint	Returns total generated fractals
(get-vertex index)	{x, y}	Returns coordinates of triangle vertices (0–2)
🧠 Private Functions
Function	Purpose
generate-sierpinski-points	Core generator using iterative Chaos Game algorithm
get-iteration-list	Creates a bounded list of iteration steps
chaos-game-step	Calculates each new point halfway toward a random vertex
hash-to-uint	Converts block hash entropy into a usable uint for randomness
🔍 How It Works

A user calls generate-fractal(iterations).

The contract:

Retrieves the previous block hash.

Iteratively applies the Chaos Game rule, moving halfway toward a randomly chosen vertex each time.

Uses Keccak256 hashing of the entropy to determine vertex selection.

The resulting points are stored permanently as on-chain data.

📊 Example Workflow
(contract-call? .chaos-game generate-fractal u500)


Returns:

(ok u1) ;; fractal ID 1


Then you can view the details:

(contract-call? .chaos-game get-fractal-points u1)
(contract-call? .chaos-game get-fractal-metadata u1)

🔒 Error Codes
Error	Code	Meaning
ERR-NOT-AUTHORIZED	u100	Action not permitted for non-owner
ERR-INVALID-ITERATIONS	u101	Exceeded maximum allowed iterations
ERR-GENERATION-FAILED	u102	Block hash could not be retrieved
🧱 Example Metadata Output
{
  iterations: u500,
  block-height: u12345,
  entropy: 0xabc123...
}

🧾 License

MIT License — free to use, modify, and deploy with attribution.