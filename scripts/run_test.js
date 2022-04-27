
const main = async() => {

    const [ propietario, superCoder] = await hre.ethers.getSigners();

    const domainContractFactory = await hre.ethers.getContractFactory('Domains');

    const domainContract = await domainContractFactory.deploy("MBSV");
    await domainContract.deployed();

    console.log("Propietario del contrato: ", propietario.address);

    let txn = await domainContract.register("Jaime", {value: hre.ethers.utils.parseEther('1234')});
    await txn.wait();

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Balance del contrato: ", hre.ethers.utils.formatEther( balance));

    //Test superCoder trata de extraer el dinero del contrato
    try{
        txn = await domainContract.connect(superCoder).withdraw();
        await txn.wait();
    }catch(error){
        console.log("Pensaste que podias robar de mi super contrato, go to you know what");
    }

    let balancePropietario = await hre.ethers.provider.getBalance(propietario.address);
    console.log("Balance del propietario antes de retirar: ",  hre.ethers.utils.formatEther(balancePropietario));

    //Propietario se dispone a retirar fondos del contrato
    txn = await domainContract.connect(propietario).withdraw();
    await txn.wait();

    const balanceContract = await hre.ethers.provider.getBalance(domainContract.address);
    balancePropietario = await hre.ethers.provider.getBalance(propietario.address);

    console.log("Balance del contrato luego de retiro: ", hre.ethers.utils.formatEther(balanceContract));
    console.log("Balance de propietario luego de retiro: ", hre.ethers.utils.formatEther(balancePropietario));

    let tx2 = await domainContract.getAllNames();
    console.log("estos: ", tx2)

}

const runMain = async () => {
    try{
        await main();
        process.exit(0);
    }catch(error){
        console.log("Error al ejecutar el contrato: ", error);
        process.exit(1);
    }
};

runMain();