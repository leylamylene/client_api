export interface User {
    _id:string,
    email:string,
    isLoggedIn: string,
    hasAcceptedRules :boolean,
    address :string,
    deviceId:string,
    walletName:string
}