
const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory("Domains");
    const domainContract = await domainContractFactory.deploy("MacroBlockchain");
    await domainContract.deployed();

    let domini = await domainContract.getDominios();
    console.log("Dominios minteados ", domini );

    console.log("Contrato desplegado en la siguiente direccion: ", domainContract.address);

    let txn = await domainContract.register("consulting", {value: hre.ethers.utils.parseEther('0.5')});
    await txn.wait();

    let dominiosAg = await domainContract.getDominios();
    console.log("Dominios minteados (agregado) ", dominiosAg );

    txn = await domainContract.setRecord("consulting", "desarrollo Blockchain");
    await txn.wait();

    let registro = await domainContract.getRecord("consulting")
    console.log("Registro establecido ", registro);

    const address = await domainContract.getAddress("consulting");
    console.log("Propietario del dominio info: ", address);

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Balance del contrato: ", hre.ethers.utils.formatEther(balance));

}

const runMain = async () => {
    try{
        await main();
        process.exit(0);
    }catch(error){
        console.log(error);
        process.exit(1);
    }
};

runMain();