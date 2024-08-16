public with sharing class UserController {
    @AuraEnabled(cacheable=true)
    public static List<UserWrapper> getUsersWithDetails(String userName) {
        // Limpa o sufixo indesejado do nome de usuário
        String cleanedUserName = cleanUserName(userName);

        // Prepara o termo de busca
        String searchTerm = '%' + cleanedUserName + '%';

        // Consulta para buscar usuários com base no nome
        List<User> users = [
            SELECT Id, Name, IsActive, Profile.Name, Email, Phone, UserRole.Name, Manager.Name
            FROM User 
            WHERE Name LIKE :searchTerm 
            LIMIT 100
        ];

        List<UserWrapper> userWrapperList = new List<UserWrapper>();

        // Itera sobre os usuários encontrados
        for (User user : users) {
            UserWrapper userWrp = new UserWrapper();
            userWrp.Id = user.Id;
            userWrp.Name = user.Name;
            userWrp.IsActive = user.IsActive;
            userWrp.ProfileName = user.Profile.Name;
            userWrp.Email = user.Email;
            userWrp.Phone = user.Phone;
            userWrp.Role = user.UserRole != null ? user.UserRole.Name : 'N/A';
            userWrp.Manager = user.Manager != null ? user.Manager.Name : 'N/A';

            // Inicializa a lista de permission sets
            userWrp.PermissionSets = new List<String>();

            // Consulta para buscar as Permission Sets associadas ao usuário, incluindo o Label
            List<PermissionSetAssignment> psaList = [
            SELECT PermissionSet.Label
            FROM PermissionSetAssignment
            WHERE AssigneeId = :user.Id
        ];

            // Adiciona os Labels das Permission Sets ao wrapper, removendo o sufixo
            for (PermissionSetAssignment psa : psaList) {
                String cleanedLabel = cleanPermissionSetLabel(psa.PermissionSet.Label);
                userWrp.PermissionSets.add(cleanedLabel);
            }

            userWrapperList.add(userWrp);
        }

        return userWrapperList;
    }

    // Método para limpar o sufixo indesejado do nome de usuário
    private static String cleanUserName(String userName) {
        String suffix = '00ex00000018ozh_128_09_04_12_1';
        if (userName != null && userName.endsWith(suffix)) {
            return userName.substring(0, userName.length() - suffix.length());
        }
        return userName;
    }

    // Método para limpar o sufixo indesejado dos labels de Permission Set
    private static String cleanPermissionSetLabel(String label) {
        // Verifique se o label não é um ID antes de limpar
        if (label != null && !label.startsWith('00e')) {
        String suffix = '00ex00000018ozh_128_09_04_12_1';
        if (label != null && label.endsWith(suffix)) {
            return label.substring(0, label.length() - suffix.length());
        }
        return label;
    }
    return null;  // Retorna null se for um ID
}

    // Classe wrapper para estruturar os dados retornados
    public class UserWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Boolean IsActive;
        @AuraEnabled public String ProfileName; // Corrigido para usar ProfileName
        @AuraEnabled public String Email;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Role; // Adicionado: Campo para Role
        @AuraEnabled public String Manager; // Adicionado: Campo para Manager
        @AuraEnabled public List<String> PermissionSets;
    }
}
