import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DecentralisedBlogModule = buildModule("DecentralisedBlogModule", (m) => {
  const decentralisedBlog = m.contract("DecentralisedBlog", [])

  return { decentralisedBlog }
})

export default DecentralisedBlogModule