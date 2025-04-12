import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BloggingModule = buildModule("BloggingModule", (m) => {
  const blogging = m.contract("Blogging", [])

  return { blogging }
})

export default BloggingModule