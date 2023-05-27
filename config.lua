Config = {}

Config.Global = {
    -----------------------------------------------------------------------------------
    Framework = "esx", -- esx = trigger / newEsx = export for legacy new version
    SharedObject = "esx:getSharedObject",
    -----------------------------------------------------------------------------------
    ColorMenuR = 255, -- Bannière couleur R
    ColorMenuG = 255, -- Bannière couleur G
    ColorMenuB = 255, -- Bannière couleur B
    ColorMenuA = 150, -- Bannière couleur A
    MenuPositionX = 0, -- Bannière position X sur l'écran
    MenuPositionY = 0, -- Bannière position Y sur l'écran
    TextColor = "~y~", -- Couleur du texte menu 
    -----------------------------------------------------------------------------------
    PropsMax = 5,
}

Config.Props = {

    {
        name = "Général",
        job = nil,
        job2 = nil,
        Props = {
            {Label = "Fauteil Roulant", Model = "prop_wheelchair_01"},
            {Label = "Chaise Camping", Model = "prop_skid_chair_01"},
            {Label = "Chaise de rue", Model = "v_ilev_chair02_ped"},
            {Label = "Canapé de rue", Model = "prop_rub_couch04"},
            {Label = "Lampe Led", Model = "prop_worklight_03a"},
            {Label = "Lampe Photo", Model = "prop_studio_light_03"},
            {Label = "Carton Drogue Blue", Model = "prop_mp_drug_pack_blue"},
            {Label = "Tabouret", Model = "prop_bar_stool_01"},
            {Label = "Caisse D'armes", Model = "prop_lev_crate_01"},
            {Label = "Chariot Lingot", Model = "prop_large_gold_alt_a"},
            {Label = "Transat", Model = "p_patio_lounger1_s"},
            {Label = "Chaise en Bois", Model = "prop_rock_chair_01"},
            {Label = "Sac Poubelle", Model = "prop_ld_rub_binbag_01"},
        },
    },

}