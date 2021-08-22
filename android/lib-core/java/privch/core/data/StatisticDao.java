package privch.core.data;

import androidx.room.Dao;
import androidx.room.Query;

@Dao
public interface StatisticDao {

    // TODO: test
    @Query("DELETE FROM statistic WHERE serverId=:serverId")
    void delete(int serverId);
}
